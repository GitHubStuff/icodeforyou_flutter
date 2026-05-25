// programs/creature_comforts/lib/src/reminders/last_fed_reminder_service.dart
import 'dart:async';

import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show LastFedFailure, LastFedService;
import 'package:fpdart/fpdart.dart';
import 'package:remind_me/remind_me.dart';
import 'package:service_locator/service_locator.dart';

/// Schedules a cascade of "Feed me!" notifications when the elapsed time
/// since the last feeding crosses a threshold.
///
/// Behavior:
///   - Subscribes to [LastFedService.watch] for the duration of the app's
///     lifetime.
///   - On every successful emission, cancels any previously-scheduled
///     reminders and computes a new cascade — but only when reminders
///     are *enabled* in-app and the OS has granted exact-alarm permission.
///   - Reminders are enabled / disabled via the in-app toggle persisted
///     under [kRemindersEnabledKey]. When disabled, the service cancels
///     all pending reminders and ignores stream events until re-enabled.
///   - The cascade fires the first reminder at `lastFed + threshold` and
///     repeats every hour until 24 hours from now (the practical limit
///     of [RemindMe.scheduleInMinutes]).
///   - On stream failures the existing schedule is left in place — a
///     transient Firestore hiccup must not silently kill the user's
///     reminders.
///
/// Independence from OS permission: this service does not prompt for OS
/// permission. It does check via [RemindMe.canScheduleExactAlarms] and
/// silently skips scheduling when the permission is absent — the
/// Notifications screen surfaces the missing permission with a Grant
/// button. The next stream event after the user grants permission will
/// re-trigger the cascade automatically, so the user does not need to
/// re-feed the pet to wake up reminders.
class LastFedReminderService implements ServiceClass {
  /// Creates the service and immediately starts watching the backend.
  ///
  /// [lastFed] is the data source for the latest feeding timestamp.
  /// [appPrefs] supplies the in-app reminders-enabled toggle.
  /// [remindMe] defaults to the singleton; tests inject a mock.
  LastFedReminderService({
    required LastFedService lastFed,
    required AppPreferences appPrefs,
    RemindMe? remindMe,
  }) : _lastFed = lastFed,
       _appPrefs = appPrefs,
       _remindMe = remindMe ?? RemindMe.instance {
    _sub = _lastFed.watch().listen(_onEvent);
    // Read the initial enabled state. When absent, default to true so
    // newly-installed users get reminders without a second opt-in step
    // beyond the OS prompt.
    _appPrefs.prefs.getBool(kRemindersEnabledKey).then((value) {
      _enabled = value ?? true;
    });
  }

  /// Persisted preference key for the in-app reminders toggle.
  ///
  /// Namespaced under the program name so package-level prefs can't
  /// collide. Use [LastFedReminderService.isEnabled] /
  /// [LastFedReminderService.setEnabled] from app code rather than
  /// reading this key directly.
  static const String kRemindersEnabledKey =
      'creature_comforts.reminders_enabled';

  /// Hours of inactivity before reminders begin firing. Hardcoded for v1.
  static const int _kDefaultThreshold = 10;

  /// Maximum hours into the future we'll schedule reminders for in one
  /// cascade. [RemindMe.scheduleInMinutes] asserts < 24 hours, so we
  /// stop at 23 to stay safely below.
  static const int _kCascadeHorizonHours = 23;

  final LastFedService _lastFed;
  final AppPreferences _appPrefs;
  final RemindMe _remindMe;
  late final StreamSubscription<Either<LastFedFailure, DateTime>> _sub;

  /// IDs of currently-scheduled reminders. Replaced wholesale on every
  /// successful event.
  final List<int> _scheduled = [];

  /// Cached enabled state. Read from prefs at construction; written
  /// through [setEnabled]. The cache lets [_onEvent] make scheduling
  /// decisions synchronously without awaiting prefs on every backend
  /// emission.
  bool _enabled = true;

  /// Cache of the most recent successful timestamp from the watch
  /// stream, kept so [setEnabled] can reschedule based on it without
  /// waiting for the next stream event.
  DateTime? _lastKnownFedAt;

  /// Whether reminders are currently enabled in-app. The OS permission
  /// state is independent — this getter reflects only the user's in-app
  /// toggle.
  bool get isEnabled => _enabled;

  /// Sets the in-app reminders toggle and reconciles the schedule.
  ///
  /// Persists [value] to preferences, then either cancels everything
  /// (when [value] is `false`) or rebuilds the cascade from the most
  /// recent known feeding timestamp (when [value] is `true`).
  Future<void> setEnabled({required bool value}) async {
    if (_enabled == value) return;
    _enabled = value;
    await _appPrefs.prefs.setBool(kRemindersEnabledKey, value);
    if (!value) {
      await _cancelAll();
      return;
    }
    final lastFed = _lastKnownFedAt;
    if (lastFed != null) {
      await _reschedule(lastFed);
    }
  }

  Future<void> _onEvent(Either<LastFedFailure, DateTime> event) async {
    final lastFed = event.toNullable();
    if (lastFed == null) return; // transient failure — keep current schedule
    _lastKnownFedAt = lastFed;
    if (!_enabled) return; // toggled off — record but do not schedule
    await _reschedule(lastFed);
  }

  /// Cancels every previously-scheduled reminder and schedules a fresh
  /// cascade based on [lastFed].
  ///
  /// Silently skips scheduling (after cancelling) when the OS has not
  /// granted exact-alarm permission. The Notifications screen surfaces
  /// the missing permission; the next stream event after the user
  /// grants it will fire this method again and the cascade will pick
  /// up automatically.
  Future<void> _reschedule(DateTime lastFed) async {
    await _cancelAll();

    // Exact-alarm permission gate. Without it, scheduleInMinutes throws
    // PlatformException(exact_alarms_not_permitted). Skipping silently
    // here lets the user-facing toggle stay "on" while the OS-level
    // grant is pending; the Notifications screen is responsible for
    // showing the user how to fix it.
    if (!await _remindMe.canScheduleExactAlarms()) return;

    final now = DateTime.now().toUtc();
    final firstFireAt = lastFed.toUtc().add(
      const Duration(hours: _kDefaultThreshold),
    );
    final horizonEnd = now.add(const Duration(hours: _kCascadeHorizonHours));

    // Walk the schedule one hour at a time, starting either at the
    // computed first fire time or at "now + 1 minute" if the first fire
    // time has already passed (i.e. elapsed already exceeds threshold).
    var fireAt = firstFireAt.isAfter(now)
        ? firstFireAt
        : now.add(const Duration(minutes: 1));

    var hoursElapsed = _kDefaultThreshold;

    while (fireAt.isBefore(horizonEnd)) {
      final delay = fireAt.difference(now);
      // Defensive: scheduleInMinutes asserts duration < 24h. If we
      // somehow drift past that, stop the cascade rather than throw.
      if (delay.inHours >= 24) break;

      final id = await _remindMe.scheduleInMinutes(
        title: 'Feed me!',
        body: "It's been $hoursElapsed hours.",
        duration: delay,
      );
      _scheduled.add(id);

      fireAt = fireAt.add(const Duration(hours: 1));
      hoursElapsed += 1;
    }
  }

  /// Cancels every reminder currently tracked by this service.
  Future<void> _cancelAll() async {
    for (final id in _scheduled) {
      await _remindMe.cancel(id);
    }
    _scheduled.clear();
  }

  /// Cancels all scheduled reminders and stops watching the backend.
  ///
  /// Call from a higher-level shutdown path; the service does not own
  /// its own teardown trigger because the locator does not currently
  /// expose a "deregister" lifecycle.
  Future<void> dispose() async {
    await _sub.cancel();
    await _cancelAll();
  }
}
