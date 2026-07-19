// lib/packages/remind_me/src/remind_me.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:remind_me/remind_me.dart' show RemindMe;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'API reference', type: RemindMeShowcase)
Widget remindMeApiReference(BuildContext context) {
  final highlight = context.knobs.object.dropdown<_ApiMethod?>(
    label: 'Highlight method',
    options: <_ApiMethod?>[null, ..._ApiMethod.values],
    initialOption: null,
    labelBuilder: (m) => m?.name ?? '(none)',
  );
  return RemindMeShowcase(highlight: highlight);
}

/// Showcase for [RemindMe]. **Documentation, not playground.** Lists the
/// singleton's public API surface with signatures, return types, and
/// platform applicability. No method is actually invoked — `RemindMe`
/// methods all bind to native plugins (`flutter_local_notifications`,
/// `permission_handler`, `flutter_timezone`) and calling them from a
/// widgetbook would either crash on unsupported hosts or schedule real
/// OS notifications on a device, neither of which is desirable.
///
/// For interactive verification, see the existing
/// `test/remind_me_test.dart`.
class RemindMeShowcase extends StatelessWidget {
  const RemindMeShowcase({this.highlight, super.key});

  final _ApiMethod? highlight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Banner(),
            const SizedBox(height: 12),
            const _SingletonCard(),
            const SizedBox(height: 12),
            for (final group in _groups) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  group.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final m in group.methods) ...[
                _MethodCard(
                  method: m,
                  highlighted: highlight == m.id,
                  dim: highlight != null && highlight != m.id,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── API data model ────────────────────────────────────────────────────────

enum _ApiMethod {
  init,
  requestPermissions,
  currentStatus,
  openSettings,
  requestExactAlarmsPermission,
  canScheduleExactAlarms,
  scheduleInMinutes,
  cancel,
}

class _Method {
  const _Method({
    required this.id,
    required this.signature,
    required this.summary,
    required this.platforms,
    this.notes,
  });

  final _ApiMethod id;
  final String signature;
  final String summary;
  final String platforms;
  final String? notes;
}

class _Group {
  const _Group({required this.title, required this.methods});
  final String title;
  final List<_Method> methods;
}

const _groups = <_Group>[
  _Group(
    title: 'Lifecycle',
    methods: [
      _Method(
        id: _ApiMethod.init,
        signature: 'Future<void> init()',
        summary: 'Initializes timezones and the underlying notifications '
            'plugin. Must be called once at app start before any other '
            'method.',
        platforms: 'iOS · Android',
        notes: 'Idempotency is not enforced — call exactly once.',
      ),
    ],
  ),
  _Group(
    title: 'Permission — notifications',
    methods: [
      _Method(
        id: _ApiMethod.requestPermissions,
        signature: 'Future<bool> requestPermissions()',
        summary: 'Shows the OS notification permission prompt. Returns '
            'true if the user granted on every platform that asked. iOS '
            'asks for alert/badge/sound; Android (13+) asks for POST_'
            'NOTIFICATIONS.',
        platforms: 'iOS · Android 13+',
      ),
      _Method(
        id: _ApiMethod.currentStatus,
        signature: 'Future<NotificationPermissionStatus> currentStatus()',
        summary: 'Reads the current permission state without prompting. '
            'Maps permission_handler\'s PermissionStatus to the package-'
            'native NotificationPermissionStatus enum.',
        platforms: 'iOS · Android',
      ),
      _Method(
        id: _ApiMethod.openSettings,
        signature: 'Future<bool> openSettings()',
        summary: 'Launches the OS app-settings screen. Use when '
            'currentStatus() returns permanentlyDenied — the user can '
            'no longer be prompted in-app.',
        platforms: 'iOS · Android',
      ),
    ],
  ),
  _Group(
    title: 'Permission — exact alarms (Android only)',
    methods: [
      _Method(
        id: _ApiMethod.canScheduleExactAlarms,
        signature: 'Future<bool> canScheduleExactAlarms()',
        summary: 'Whether SCHEDULE_EXACT_ALARM has been granted. Returns '
            'true on iOS (the concept does not apply).',
        platforms: 'Android 12+ (always true on iOS)',
      ),
      _Method(
        id: _ApiMethod.requestExactAlarmsPermission,
        signature: 'Future<bool> requestExactAlarmsPermission()',
        summary: 'Requests SCHEDULE_EXACT_ALARM if not already granted. '
            'Required for AndroidScheduleMode.exactAllowWhileIdle on '
            'Android 12+. No-op on iOS.',
        platforms: 'Android 12+',
      ),
    ],
  ),
  _Group(
    title: 'Scheduling',
    methods: [
      _Method(
        id: _ApiMethod.scheduleInMinutes,
        signature: 'Future<int> scheduleInMinutes({\n'
            '  required String title,\n'
            '  required String body,\n'
            '  Duration duration = const Duration(minutes: 5),\n'
            '})',
        summary: 'Schedules a local notification at now + duration. '
            'Returns the platform-stable notification id that can be '
            'passed to cancel().',
        platforms: 'iOS · Android',
        notes: 'Asserts duration < 24h. Uses exactAllowWhileIdle on '
            'Android — pair with requestExactAlarmsPermission() on '
            'Android 12+.',
      ),
      _Method(
        id: _ApiMethod.cancel,
        signature: 'Future<void> cancel(int id)',
        summary: 'Cancels the scheduled notification with the given id. '
            'No-op if the id does not correspond to a pending '
            'notification.',
        platforms: 'iOS · Android',
      ),
    ],
  ),
];

// ─── UI bits ────────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.amber.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.amber.shade900),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference only',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'RemindMe binds to native plugins. Methods are not '
                    'invoked here — calling them from a widgetbook would '
                    'either throw MissingPluginException on unsupported '
                    'hosts or schedule real OS notifications on a device. '
                    'See test/remind_me_test.dart for interactive '
                    'verification with mocked channels.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingletonCard extends StatelessWidget {
  const _SingletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Singleton access',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const SelectableText(
              'final remindMe = RemindMe.instance;',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Private constructor; one shared instance per process. '
              'Holds the FlutterLocalNotificationsPlugin handle for the '
              'lifetime of the app.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.highlighted,
    required this.dim,
  });

  final _Method method;
  final bool highlighted;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.35 : 1.0,
      child: Card(
        margin: EdgeInsets.zero,
        color: highlighted ? Colors.indigo.withValues(alpha: 0.08) : null,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: highlighted ? Colors.indigo : Colors.black12,
            width: highlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                method.signature,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(method.summary),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_iphone,
                    size: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    method.platforms,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              if (method.notes != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    method.notes!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
