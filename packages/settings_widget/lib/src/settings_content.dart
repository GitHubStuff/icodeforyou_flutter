// packages/settings_widget/lib/src/settings_content.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:settings_widget/src/app_settings_entry.dart';
import 'package:settings_widget/src/settings_dismiss_button.dart';

/// The body of a settings surface, usable either as a modal overlay or as a
/// navigation destination.
///
/// Renders, top to bottom:
///
///  1. A [SettingsDismissButton] wired to [onDismiss] — **only when
///     [onDismiss] is non-null**.
///  2. The [title], styled bold at 24pt via [DefaultTextStyle.merge] so the
///     caller may pass any widget (typically a [Text]) without pre-styling
///     it.
///  3. The [entries], vertically spaced and wrapped in a
///     [SingleChildScrollView] inside a [Flexible] so the column shrinks to
///     fit short lists yet scrolls when content exceeds the available
///     height.
///
/// ## Overlay or destination
///
/// The nullable [onDismiss] is what lets one body serve both callers:
///
/// * **Overlay** — pushed over the current screen by `SettingsWidget.show`,
///   which always supplies a callback. The close button appears and is the
///   only way out, per that path's single-dismissal-affordance contract.
/// * **Destination** — a member of a navigation stack, such as a rail's
///   settings screen. Nothing needs dismissing here: the rail is how the
///   user leaves. Passing `null` omits the button rather than painting a
///   control with nowhere to go.
///
/// Nothing else varies between the two. This widget knows nothing of
/// orientation or of Material versus Cupertino; it lays out Material
/// widgets and inherits its colors and text styles from the ambient
/// [Theme].
///
/// Layout only: it owns no state and performs no persistence. Each
/// [AppSettingsEntry] handles its own value.
class SettingsContent extends StatelessWidget {
  /// Creates the settings surface body.
  ///
  /// [entries] may be empty, in which case only the [title] — and the
  /// dismiss button, if [onDismiss] is given — is shown.
  const SettingsContent({
    required this.title,
    required this.entries,
    super.key,
    this.onDismiss,
  });

  /// The heading displayed at the top of the surface.
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
  /// `null` — the default — omits the button entirely, which is the correct
  /// configuration when this body is a navigation destination rather than
  /// an overlay. Non-null typically pops the enclosing route or sheet.
  final VoidCallback? onDismiss;

  /// Uniform spacing, in logical pixels, used for horizontal padding, the
  /// title-to-list gap, scroll-view padding, and inter-entry gaps.
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    final dismiss = onDismiss;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dismiss != null) SettingsDismissButton(onDismiss: dismiss),
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
