// programs/creature_comforts/lib/src/notifications/notifications_screen.dart
import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:creature_comforts/descriptors/last_fed_reminder_descriptor.dart';
import 'package:creature_comforts/src/reminders/last_fed_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/remind_me.dart';
import 'package:service_locator/service_locator.dart';

/// Storage key for the "user has decided about notification permission" flag.
///
/// Mirrors the constant in `app_shell.dart` — kept in sync because the
/// shell reads this flag to decide the initial tab and this screen writes
/// it on first user action.
const _kNotificationsDecidedKey = 'notifications_permission_decided';

/// Notifications tab.
///
/// Composed of independently-rendered sections so v1 ships the
/// permission UI, the exact-alarms permission UI, and the in-app
/// reminders toggle, and future versions drop in a threshold slider,
/// scheduled-reminders list, or any other notification-related controls
/// without restructuring the screen.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _PermissionStatusSection(),
            _ExactAlarmsSection(),
            _RemindersToggleSection(),
            // Future sections drop in here:
            //   _ThresholdSection(),
            //   _ScheduledRemindersSection(),
          ],
        ),
      ),
    );
  }
}

/// Section: shows the current OS notification permission status and
/// offers the appropriate action button(s).
///
/// Owns the lifecycle of the "decided" flag — flipping it to `true` the
/// first time the user taps Request, regardless of whether they grant
/// the permission. Tapping Open Settings does not flip the flag because
/// it can be tapped from any state and is a navigation, not a decision.
class _PermissionStatusSection extends StatefulWidget {
  const _PermissionStatusSection();

  @override
  State<_PermissionStatusSection> createState() =>
      _PermissionStatusSectionState();
}

class _PermissionStatusSectionState extends State<_PermissionStatusSection>
    with WidgetsBindingObserver {
  NotificationPermissionStatus? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-read the permission status when the user returns to the app —
  /// they may have flipped the toggle in system Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
  }

  Future<void> _refreshStatus() async {
    final status = await RemindMe.instance.currentStatus();
    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _onRequestPressed() async {
    setState(() => _busy = true);
    await RemindMe.instance.requestPermissions();
    await _markDecided();
    await _refreshStatus();
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _onOpenSettingsPressed() async {
    setState(() => _busy = true);
    await RemindMe.instance.openSettings();
    if (!mounted) return;
    setState(() => _busy = false);
    // The lifecycle observer re-reads status on resume.
  }

  Future<void> _markDecided() async {
    final prefs = ServiceRegistry.R
        .getSync<AppPreferences>('AppPreferences')
        .prefs;
    await prefs.setBool(_kNotificationsDecidedKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null) {
      return const _SectionCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification permission',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _PermissionStatusRow(status: status),
          const SizedBox(height: 16),
          _PermissionActions(
            status: status,
            busy: _busy,
            onRequest: _onRequestPressed,
            onOpenSettings: _onOpenSettingsPressed,
          ),
        ],
      ),
    );
  }
}

/// Section: shows whether exact-alarm scheduling is permitted and
/// offers a button to request it when not.
///
/// On Android 14+ scheduling exact alarms (used by the reminder
/// cascade) requires a separate permission from the regular notification
/// permission. Without it, [LastFedReminderService] silently skips
/// scheduling — this section makes the missing permission visible and
/// recoverable. iOS does not have this concept; the platform check
/// returns `true` unconditionally, so this section displays "Allowed"
/// and no action button.
class _ExactAlarmsSection extends StatefulWidget {
  const _ExactAlarmsSection();

  @override
  State<_ExactAlarmsSection> createState() => _ExactAlarmsSectionState();
}

class _ExactAlarmsSectionState extends State<_ExactAlarmsSection>
    with WidgetsBindingObserver {
  bool? _allowed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-read the status when the user returns to the app —
  /// requesting exact-alarms permission on Android opens a settings
  /// page in another activity; the answer is only available after they
  /// flip the toggle and come back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final allowed = await RemindMe.instance.canScheduleExactAlarms();
    if (!mounted) return;
    setState(() => _allowed = allowed);
  }

  Future<void> _onAllowPressed() async {
    setState(() => _busy = true);
    await RemindMe.instance.requestExactAlarmsPermission();
    if (!mounted) return;
    setState(() => _busy = false);
    // Lifecycle observer re-reads on resume.
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _allowed;
    if (allowed == null) {
      return const _SectionCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exact reminders',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Lets reminders fire at the scheduled minute.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          _AllowedRow(allowed: allowed),
          if (!allowed) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _onAllowPressed,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Allow'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section: in-app reminders toggle.
///
/// Independent from OS permission — flipping this switch off cancels
/// pending reminders and stops scheduling new ones, regardless of
/// whether the OS would have allowed delivery. Flipping it on resumes
/// scheduling based on the most recent feeding timestamp the reminder
/// service has seen.
class _RemindersToggleSection extends StatefulWidget {
  const _RemindersToggleSection();

  @override
  State<_RemindersToggleSection> createState() =>
      _RemindersToggleSectionState();
}

class _RemindersToggleSectionState extends State<_RemindersToggleSection> {
  late final LastFedReminderService _reminders;
  bool _enabled = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reminders = ServiceRegistry.R.getSync<LastFedReminderService>(
      LastFedReminderDescriptor.kName,
    );
    _enabled = _reminders.isEnabled;
  }

  Future<void> _onToggle({required bool value}) async {
    setState(() => _busy = true);
    await _reminders.setEnabled(value: value);
    if (!mounted) return;
    setState(() {
      _enabled = value;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send reminders',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Notify me when the cat hasn\'t been fed for a while.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _enabled,
            onChanged: _busy ? null : (v) => _onToggle(value: v),
            title: Text(_enabled ? 'On' : 'Off'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

/// Visual indicator + text label for the current notification permission
/// status.
class _PermissionStatusRow extends StatelessWidget {
  const _PermissionStatusRow({required this.status});

  final NotificationPermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (status) {
      NotificationPermissionStatus.granted => (
          Icons.check_circle,
          'Enabled',
          Colors.green,
        ),
      NotificationPermissionStatus.denied => (
          Icons.cancel,
          'Disabled',
          colors.error,
        ),
      NotificationPermissionStatus.permanentlyDenied => (
          Icons.block,
          'Disabled (open system settings to change)',
          colors.error,
        ),
      NotificationPermissionStatus.restricted => (
          Icons.lock_outline,
          'Restricted by device policy',
          colors.error,
        ),
      NotificationPermissionStatus.notDetermined => (
          Icons.help_outline,
          'Not yet decided',
          colors.onSurfaceVariant,
        ),
    };
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}

/// Visual indicator + text label for the exact-alarms permission state.
class _AllowedRow extends StatelessWidget {
  const _AllowedRow({required this.allowed});

  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, label, color) = allowed
        ? (Icons.check_circle, 'Allowed', Colors.green)
        : (Icons.cancel, 'Not allowed', colors.error);
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}

/// Action buttons for the notification permission section.
///
/// Renders one or two buttons based on status:
///
/// - `notDetermined` / `denied` → "Request permission" (primary), plus
///   "Open system settings" (secondary, always available so users who
///   know what they want can skip the prompt).
/// - `permanentlyDenied` / `restricted` → "Open system settings" only,
///   since the OS will no longer surface the in-app prompt.
/// - `granted` → "Open system settings" only, so users can revoke the
///   previously-granted permission without hunting through OS settings
///   manually.
class _PermissionActions extends StatelessWidget {
  const _PermissionActions({
    required this.status,
    required this.busy,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final NotificationPermissionStatus status;
  final bool busy;
  final Future<void> Function() onRequest;
  final Future<void> Function() onOpenSettings;

  bool get _showRequest => switch (status) {
        NotificationPermissionStatus.notDetermined ||
        NotificationPermissionStatus.denied =>
          true,
        NotificationPermissionStatus.granted ||
        NotificationPermissionStatus.permanentlyDenied ||
        NotificationPermissionStatus.restricted =>
          false,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_showRequest)
          FilledButton(
            onPressed: busy ? null : onRequest,
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Request permission'),
          ),
        OutlinedButton(
          onPressed: busy ? null : onOpenSettings,
          child: const Text('Open system settings'),
        ),
      ],
    );
  }
}

/// Shared container styling for sections. Centralised so adding
/// `_ThresholdSection` and `_ScheduledRemindersSection` later picks up
/// the same look without duplication.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
