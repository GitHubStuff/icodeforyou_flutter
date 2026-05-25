// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:settings_widget/settings_widget.dart' show AppSettingsEntry;

class ThemeEntry extends AppSettingsEntry {
  const ThemeEntry({super.key});

  @override
  Widget get title => const Text('Theme');

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: title,
      subtitle: const Text('Light / Dark / System'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class NotificationsEntry extends AppSettingsEntry {
  const NotificationsEntry({super.key});

  @override
  Widget get title => const Text('Notifications');

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: title,
      subtitle: const Text('Manage alerts'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
