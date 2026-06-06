// lib/packages/remind_me/src/notification_permission_status.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:remind_me/remind_me.dart' show NotificationPermissionStatus;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(
  name: 'State picker',
  type: NotificationPermissionStatusShowcase,
)
Widget notificationPermissionStatusPicker(BuildContext context) {
  final selected =
      context.knobs.object.dropdown<NotificationPermissionStatus>(
    label: 'Selected status',
    options: NotificationPermissionStatus.values,
    initialOption: NotificationPermissionStatus.notDetermined,
    labelBuilder: (s) => s.name,
  );
  return NotificationPermissionStatusShowcase(selected: selected);
}

@widgetbook.UseCase(
  name: 'All states overview',
  type: NotificationPermissionStatusShowcase,
)
Widget notificationPermissionStatusOverview(BuildContext context) {
  return const NotificationPermissionStatusShowcase(selected: null);
}

/// Showcase for [NotificationPermissionStatus]. Documents each variant
/// with the UI affordance that should map to it, plus the recommended
/// `switch` arms.
///
/// When [selected] is non-null, only that variant is highlighted; when
/// null, every variant is shown side-by-side.
class NotificationPermissionStatusShowcase extends StatelessWidget {
  const NotificationPermissionStatusShowcase({
    required this.selected,
    super.key,
  });

  final NotificationPermissionStatus? selected;

  static const _entries =
      <(NotificationPermissionStatus, String, String, IconData, Color)>[
    (
      NotificationPermissionStatus.granted,
      'Permission granted',
      'Notifications can be scheduled and delivered. No further user '
          'action is required.',
      Icons.check_circle,
      Colors.green,
    ),
    (
      NotificationPermissionStatus.denied,
      'Denied — re-promptable',
      'User declined the prompt but can still be asked again. Show a '
          '"Request" button that calls RemindMe.requestPermissions().',
      Icons.help_outline,
      Colors.orange,
    ),
    (
      NotificationPermissionStatus.permanentlyDenied,
      'Permanently denied',
      'Re-prompting is not possible. The only path forward is to send '
          'the user to OS settings — call RemindMe.openSettings().',
      Icons.do_disturb_on,
      Colors.red,
    ),
    (
      NotificationPermissionStatus.restricted,
      'Restricted by policy',
      'Parental controls or device-management policy is blocking '
          'notifications. The user cannot grant from settings alone; an '
          'administrator must intervene.',
      Icons.shield,
      Colors.deepPurple,
    ),
    (
      NotificationPermissionStatus.notDetermined,
      'Not yet requested',
      'No prompt has been shown yet. The first call to '
          'RemindMe.requestPermissions() will display the OS dialog.',
      Icons.help_center,
      Colors.blueGrey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final entry in _entries) ...[
              _StatusCard(
                status: entry.$1,
                title: entry.$2,
                blurb: entry.$3,
                icon: entry.$4,
                color: entry.$5,
                highlighted: selected == null || selected == entry.$1,
                dim: selected != null && selected != entry.$1,
              ),
              const SizedBox(height: 12),
            ],
            const _SwitchArmsCard(),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.title,
    required this.blurb,
    required this.icon,
    required this.color,
    required this.highlighted,
    required this.dim,
  });

  final NotificationPermissionStatus status;
  final String title;
  final String blurb;
  final IconData icon;
  final Color color;
  final bool highlighted;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.35 : 1.0,
      child: Card(
        margin: EdgeInsets.zero,
        color: highlighted ? color.withValues(alpha: 0.08) : null,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: highlighted ? color : Colors.black12,
            width: highlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NotificationPermissionStatus.${status.name}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(blurb),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchArmsCard extends StatelessWidget {
  const _SwitchArmsCard();

  static const _code = '''switch (await RemindMe.instance.currentStatus()) {
  NotificationPermissionStatus.granted =>
    // ready to schedule
    null,
  NotificationPermissionStatus.denied ||
  NotificationPermissionStatus.notDetermined =>
    RemindMe.instance.requestPermissions(),
  NotificationPermissionStatus.permanentlyDenied =>
    RemindMe.instance.openSettings(),
  NotificationPermissionStatus.restricted =>
    showRestrictedByPolicyDialog(),
}''';

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
              'Recommended switch arms',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SelectableText(
              _code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
