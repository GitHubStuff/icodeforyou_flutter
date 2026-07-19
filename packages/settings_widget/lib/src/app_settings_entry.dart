// packages/settings_widget/lib/src/app_settings_entry.dart

import 'package:flutter/material.dart';

/// Abstract base for a single row in a settings list.
///
/// Subclasses must provide a [title] widget and implement [build] to render
/// the full row. By extending [StatelessWidget] directly, each entry remains
/// side-effect-free and trivially testable.
abstract class AppSettingsEntry extends StatelessWidget {
  /// Creates an [AppSettingsEntry].
  const AppSettingsEntry({super.key});

  /// The primary label widget displayed for this settings entry.
  ///
  /// Typically a [Text] widget, but any widget is valid. Implementations
  /// should keep the title concise so it fits comfortably on a single line.
  Widget get title;
}
