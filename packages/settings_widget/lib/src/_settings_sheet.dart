// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:settings_widget/src/_app_settings_entry.dart';
import 'package:settings_widget/src/_settings_content.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    required this.title,
    required this.entries,
    required this.onDismiss,
    required this.breakpoint,
    super.key,
  });

  final Widget title;
  final List<AppSettingsEntry> entries;
  final VoidCallback onDismiss;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= breakpoint;

    final content = SettingsContent(
      title: title,
      entries: entries,
      onDismiss: onDismiss,
    );

    if (isWide) return _TabletSheet(content: content);
    return _PhoneSheet(content: content);
  }
}

class _PhoneSheet extends StatelessWidget {
  const _PhoneSheet({required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: content);
  }
}

class _TabletSheet extends StatelessWidget {
  const _TabletSheet({required this.content});

  final Widget content;

  static const double _padding = 48;
  static const double _bottomPadding = 96;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: _padding,
        right: _padding,
        top: _padding,
        bottom: _bottomPadding,
      ),
      child: Center(child: content),
    );
  }
}
