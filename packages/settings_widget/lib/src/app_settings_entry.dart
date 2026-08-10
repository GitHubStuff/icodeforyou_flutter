// packages/settings_widget/lib/src/app_settings_entry.dart

import 'package:flutter/material.dart';

/// Abstract base for a single row in a settings list.
///
/// Declares no members: it exists to type the list a settings surface
/// accepts, so `entries` cannot be handed an arbitrary widget. Subclasses
/// implement [build] and nothing else.
///
/// The former `title` getter is gone. No surface in this package ever read
/// it — `SettingsContent` lays out each entry's [build] output directly —
/// so it obliged every implementor to expose a public member for the
/// framework's benefit that the framework never consumed, and forced an
/// `ignore_for_file: public_member_api_docs` on entry files to satisfy the
/// lint. An entry that wants a label declares it privately, or inlines it.
///
/// ## Example
///
/// ```dart
/// class NotificationsEntry extends AppSettingsEntry {
///   const NotificationsEntry({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return const ListTile(
///       leading: Icon(Icons.notifications_outlined),
///       title: Text('Notifications'),
///       subtitle: Text('Manage alerts'),
///     );
///   }
/// }
/// ```
abstract class AppSettingsEntry extends StatelessWidget {
  /// Creates an [AppSettingsEntry].
  const AppSettingsEntry({super.key});
}
