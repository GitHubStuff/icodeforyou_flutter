// packages/settings_widget/lib/src/settings_content.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:settings_widget/src/app_settings_entry.dart';
import 'package:settings_widget/src/settings_dismiss_button.dart';

/// The scrollable body of the settings surface.
///
/// Renders, top to bottom:
///
///  1. A [SettingsDismissButton] wired to [onDismiss].
///  2. The [title], styled bold at 24pt via [DefaultTextStyle.merge] so the
///     caller may pass any widget (typically a [Text]) without pre-styling it.
///  3. The [entries], vertically spaced and wrapped in a
///     [SingleChildScrollView] inside a [Flexible] so the column shrinks to
///     fit short lists yet scrolls when content exceeds the available height.
///
/// This widget is layout-only: it owns no state and performs no persistence.
/// Each [AppSettingsEntry] is responsible for its own value handling.
class SettingsContent extends StatelessWidget {
  /// Creates the settings surface body.
  ///
  /// All parameters are required; [entries] may be empty, in which case only
  /// the dismiss button and [title] are shown.
  const SettingsContent({
    required this.title,
    required this.entries,
    required this.onDismiss,
    super.key,
  });

  /// The heading displayed beneath the dismiss button.
  ///
  /// Styled bold, 24pt via [DefaultTextStyle.merge]; pass a plain [Text] and
  /// the styling is applied automatically. Any widget is accepted, so a
  /// [Row] with an icon, for example, works equally well.
  final Widget title;

  /// The settings rows to display, in order, separated by a [Gap] of
  /// [_gap] logical pixels.
  final List<AppSettingsEntry> entries;

  /// Invoked when the user taps the [SettingsDismissButton].
  ///
  /// Typically pops the enclosing route or sheet.
  final VoidCallback onDismiss;

  /// Uniform spacing, in logical pixels, used for horizontal padding, the
  /// title-to-list gap, scroll-view padding, and inter-entry gaps.
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsDismissButton(onDismiss: onDismiss),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gap),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            child: title,
          ),
        ),
        const Gap(_gap),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_gap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _spacedEntries,
            ),
          ),
        ),
      ],
    );
  }

  /// [entries] interleaved with a [Gap] of [_gap] between consecutive
  /// items; no trailing gap is appended after the final entry.
  List<Widget> get _spacedEntries {
    final spaced = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      spaced.add(entries[i]);
      if (i < entries.length - 1) spaced.add(const Gap(_gap));
    }
    return spaced;
  }
}
