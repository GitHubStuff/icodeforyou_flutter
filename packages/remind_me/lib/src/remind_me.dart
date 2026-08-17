// packages/remind_me/lib/src/remind_me.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart' show FlutterTimezone;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:remind_me/src/notification_permission_status.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// {@template remind_me.RemindMe}
/// Singleton facade over `flutter_local_notifications` for scheduling
/// one-shot local reminder notifications.
///
/// Call [init] exactly once before any other member. Permission
/// handling is explicit and deferred: [init] never prompts the user —
/// call [requestPermissions] (and, on Android, optionally
/// [requestExactAlarmsPermission]) from an appropriate point in the UI
/// flow instead.
///
/// All reminders are posted on a single Android notification channel
/// (`reminders`).
/// {@endtemplate}
class RemindMe {
  RemindMe._();

  /// {@template remind_me.RemindMe.instance}
  /// The single shared instance.
  /// {@endtemplate}
  static final RemindMe instance = RemindMe._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'reminders';
  static const _channelName = 'Reminders';

  /// {@template remind_me.RemindMe.init}
  /// Initializes the timezone database and the underlying notifications
  /// plugin.
  ///
  /// Resolves the device's local timezone and sets it as the `timezone`
  /// package's local location, so that [scheduleInMinutes] fires at the
  /// correct wall-clock instant across DST transitions.
  ///
  /// Deliberately initializes iOS with all permission request flags
  /// disabled — no system prompt is shown. Call [requestPermissions]
  /// when the UI is ready to ask.
  ///
  /// Must complete before any other member is used.
  /// {@endtemplate}
  Future<void> init() async {
    tzdata.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// {@template remind_me.RemindMe.requestPermissions}
  /// Prompts the user for notification permission via the OS dialog.
  ///
  /// On iOS this requests alert, badge, and sound permission; on
  /// Android 13+ it requests `POST_NOTIFICATIONS`. Each platform's
  /// prompt is one-shot at the OS level — once the user has denied it,
  /// subsequent calls are a no-op and [openSettings] is the only
  /// remaining path. Check [currentStatus] first to decide which action
  /// to offer.
  ///
  /// Returns `true` when permission is granted on the current platform.
  /// A missing platform implementation (e.g. the iOS implementation on
  /// an Android device) counts as granted, so the result reflects only
  /// the platform the app is actually running on.
  /// {@endtemplate}
  Future<bool> requestPermissions() async {
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosOk = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidOk = await androidImpl?.requestNotificationsPermission();

    return (iosOk ?? true) && (androidOk ?? true);
  }

  /// {@template remind_me.RemindMe.requestExactAlarmsPermission}
  /// Requests the Android exact-alarm capability if not already held.
  ///
  /// On Android 12+ (API 31), `SCHEDULE_EXACT_ALARM` gates
  /// [scheduleInMinutes]'s `exactAllowWhileIdle` schedule mode. This
  /// first checks the current state and returns `true` immediately if
  /// the capability is already granted; otherwise it launches the
  /// system's exact-alarm settings flow and reports the outcome.
  ///
  /// Always returns `true` on non-Android platforms, where the concept
  /// does not exist.
  /// {@endtemplate}
  Future<bool> requestExactAlarmsPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl == null) return true;

    final granted = await androidImpl.canScheduleExactNotifications() ?? false;
    if (granted) return true;

    return await androidImpl.requestExactAlarmsPermission() ?? false;
  }

  /// {@template remind_me.RemindMe.canScheduleExactAlarms}
  /// Reports whether exact alarms can currently be scheduled, without
  /// prompting or launching any settings flow.
  ///
  /// Use this on screens that need to display exact-alarm state or
  /// decide whether to surface [requestExactAlarmsPermission]. Always
  /// returns `true` on non-Android platforms.
  /// {@endtemplate}
  Future<bool> canScheduleExactAlarms() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl == null) return true;
    return await androidImpl.canScheduleExactNotifications() ?? false;
  }

  /// {@template remind_me.RemindMe.currentStatus}
  /// Reads the current OS notification permission state without
  /// prompting the user.
  ///
  /// Use this on screens that need to display permission state or pick
  /// between "request" and "open settings" actions. Cheap to call.
  ///
  /// Returns [NotificationPermissionStatus.notDetermined] when the user
  /// has not yet been prompted, [NotificationPermissionStatus.granted]
  /// after consent, [NotificationPermissionStatus.denied] when the user
  /// declined but can still be re-prompted, and
  /// [NotificationPermissionStatus.permanentlyDenied] when the OS will
  /// no longer surface the prompt — the only path forward from this
  /// state is [openSettings].
  /// {@endtemplate}
  Future<NotificationPermissionStatus> currentStatus() async {
    final raw = await ph.Permission.notification.status;
    return switch (raw) {
      ph.PermissionStatus.granted ||
      ph.PermissionStatus.provisional => NotificationPermissionStatus.granted,
      ph.PermissionStatus.denied => NotificationPermissionStatus.denied,
      ph.PermissionStatus.permanentlyDenied =>
        NotificationPermissionStatus.permanentlyDenied,
      ph.PermissionStatus.restricted => NotificationPermissionStatus.restricted,
      // `limited` is iOS-only and used by other permissions (e.g.
      // photos); for notifications it does not occur in practice but is
      // mapped to `granted` to be safe — the user has elected to allow
      // some notifications.
      ph.PermissionStatus.limited => NotificationPermissionStatus.granted,
    };
  }

  /// {@template remind_me.RemindMe.openSettings}
  /// Opens the OS settings screen for this app, where the user can
  /// toggle notification permission directly.
  ///
  /// Returns `true` if the settings screen was successfully launched.
  /// Use this from UI shown when [currentStatus] returns
  /// [NotificationPermissionStatus.permanentlyDenied] (the user can
  /// no longer be prompted in-app), or as an always-available secondary
  /// action so users can revoke previously-granted permission without
  /// hunting through OS settings manually.
  /// {@endtemplate}
  Future<bool> openSettings() => ph.openAppSettings();

  /// {@template remind_me.RemindMe.scheduleInMinutes}
  /// Schedules a one-shot reminder notification [duration] from now.
  ///
  /// The notification carries [title] and [body] and is delivered on
  /// the shared `reminders` channel at high importance and priority.
  /// Scheduling uses `AndroidScheduleMode.exactAllowWhileIdle`, so on
  /// Android 12+ delivery is only exact when
  /// [canScheduleExactAlarms] reports `true` — see
  /// [requestExactAlarmsPermission].
  ///
  /// [duration] defaults to five minutes and must be strictly less than
  /// 24 hours (asserted in debug builds).
  ///
  /// Returns the generated notification id, derived from the current
  /// epoch milliseconds truncated to a 31-bit value. Retain it to
  /// [cancel] the reminder later. Because the id is time-derived, two
  /// calls within the same millisecond would collide; at UI-driven call
  /// rates this does not occur.
  /// {@endtemplate}
  Future<int> scheduleInMinutes({
    required String title,
    required String body,
    Duration duration = const Duration(minutes: 5),
  }) async {
    assert(duration.inHours < Duration.hoursPerDay, 'Duration must be < 24hrs');
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    final when = tz.TZDateTime.now(tz.local).add(duration);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'User-set reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    return id;
  }

  /// {@template remind_me.RemindMe.cancel}
  /// Cancels the scheduled (or already-displayed) notification with the
  /// given [id], as returned by [scheduleInMinutes].
  ///
  /// Cancelling an unknown id is a harmless no-op.
  /// {@endtemplate}
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
