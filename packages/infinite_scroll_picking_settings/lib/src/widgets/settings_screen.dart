// infinite_scroll_picking_settings/lib/src/widgets/settings_screen.dart

// ignore_for_file: comment_references, always_use_package_imports, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

import '../picker_visual_settings/picker_visual_settings.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_mapper.dart';
import '../settings/settings_state/settings_state.dart';

part 'settings_screen_sections.dart';
part 'settings_screen_widgets.dart';

// ── Layout / preview ─────────────────────────────────────────────────────────

const _kPagePadding = 18.0;
const _kPinnedHeaderVPad = 12.0;
const _kPreviewItemCount = 100;

// ─────────────────────────────────────────────────────────────────────────────

/// A full-screen settings editor for a [PickerVisualSettings].
///
/// Drops a live-updating [InfiniteScrollPicker] preview at the top of the
/// screen and a scrollable controls panel below. Every control mutates the
/// [SettingsCubit] state, which drives both the preview and the AppBar's
/// save/reset/clear actions.
///
/// The cubit must be provided above this widget — typically via
/// `BlocProvider<SettingsCubit>(...)`. The cubit constructs already in
/// `loaded` state (seeded from a [SettingsHolder] populated at app
/// startup by [SettingsLoader]), so this screen never shows a loading
/// spinner under normal flow — the [SettingsInitial]/[SettingsLoading]
/// arms below are defensive only.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picker Settings'),
        actions: const [_SaveAction(), _ResetAction(), _ClearAction()],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => switch (state) {
          SettingsInitial() || SettingsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SettingsError(:final message) => _ErrorView(message: message),
          SettingsLoaded() => _LoadedView(state: state),
        },
      ),
    );
  }
}

// ── Loaded view: pinned preview + scrollable controls ────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final SettingsLoaded state;

  void _emit(BuildContext context, PickerVisualSettings next) {
    context.read<SettingsCubit>().updateSettings(next);
  }

  @override
  Widget build(BuildContext context) {
    final s = state.settings;
    return Column(
      children: [
        _PreviewHeader(settings: s),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_kPagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FrameSection(
                  settings: s,
                  onChanged: (next) => _emit(context, next),
                ),
                const SizedBox(height: 20),
                _WheelDimensionsSection(
                  settings: s,
                  onChanged: (next) => _emit(context, next),
                ),
                const SizedBox(height: 20),
                _SelectionBandSection(
                  settings: s,
                  onChanged: (next) => _emit(context, next),
                ),
                const SizedBox(height: 20),
                _PerspectiveSection(
                  settings: s,
                  onChanged: (next) => _emit(context, next),
                ),
                const SizedBox(height: 20),
                _PickerSection(
                  settings: s,
                  onChanged: (next) => _emit(context, next),
                ),
                const SizedBox(height: 20),
                _StateReadout(settings: s, isDirty: state.isDirty),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
