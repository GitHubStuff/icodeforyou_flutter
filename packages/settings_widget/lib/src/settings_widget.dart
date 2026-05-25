// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:settings_widget/src/_app_settings_entry.dart';
import 'package:settings_widget/src/_settings_direction.dart';
import 'package:settings_widget/src/_settings_layout.dart';
import 'package:settings_widget/src/_settings_sheet.dart';
import 'package:settings_widget/src/_settings_transition.dart';

const double kSettingsBreakpoint = 100;

abstract final class SettingsWidget {
  static const double _defaultEdgeGap = 16;

  static Future<void> show(
    BuildContext context, {
    required List<AppSettingsEntry> entries,
    Widget title = const Text(
      'Settings...',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    double breakpoint = kSettingsBreakpoint,
    SettingsDirection direction = SettingsDirection.bottom,
    double edgeGap = _defaultEdgeGap,
    bool useRootNavigator = false, // ← add this
  }) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: useRootNavigator, // ← thread through
      barrierDismissible: false,
      barrierLabel: 'Settings',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => SettingsLayout(
        direction: direction,
        edgeGap: edgeGap,
        child: SettingsSheet(
          title: title,
          entries: entries,
          onDismiss: () => Navigator.of(
            context,
            rootNavigator: useRootNavigator,
          ).pop(), // ← match
          breakpoint: breakpoint,
        ),
      ),
      transitionBuilder: (_, animation, _, child) => SettingsTransition(
        animation: animation,
        direction: direction,
        child: child,
      ),
    );
  }
}
