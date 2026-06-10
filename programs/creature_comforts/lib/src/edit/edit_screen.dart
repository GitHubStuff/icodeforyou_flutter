// programs/creature_comforts/lib/src/edit/edit_screen.dart
// ignore_for_file: public_member_api_docs

import 'package:creature_comforts/descriptors/last_fed_descriptor.dart' show LastFedServiceDescriptor;
import 'package:creature_comforts/src/haptics/haptics_cubit.dart' show HapticsCubit;
import 'package:creature_comforts/src/widgets/last_fed_display.dart' show LastFedDisplay;
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show LastFedService;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart' show DateTimePickerPopover;
import 'package:service_locator/service_locator.dart' show ServiceRegistry;

/// Edit screen — same visible layout as Home (pet image + LastFedDisplay)
/// but the FED button is replaced by a date/time picker.
///
/// Tapping the picker opens [DateTimePickerPopover.show], anchored to the
/// button. On confirm (a non-null [DateTime] return), the picked moment
/// is written via [LastFedService.update] and propagates to every
/// subscribed user through the realtime stream.
///
/// The pet image is intentionally not duplicated here — the Edit screen
/// is task-focused (correcting a wrong timestamp), so a smaller, denser
/// layout is appropriate. If you want the pet image here too, drop a
/// `_PetImage()` line at the top of the column.
class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final GlobalKey<State<StatefulWidget>> _anchorKey = GlobalKey();
  bool _busy = false;

  Future<void> _onPickPressed() async {
    context.read<HapticsCubit>().tap();

    final picked = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _anchorKey,
      initialDateTime: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    final service = ServiceRegistry.R.getSync<LastFedService>(
      LastFedServiceDescriptor.kName,
    );
    final result = await service.update(occurredAt: picked.toUtc());

    if (!mounted) return;
    setState(() => _busy = false);

    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        // Success path is silent — LastFedDisplay above resets via the
        // realtime stream, which is the visible acknowledgement.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit last fed')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LastFedDisplay(),
                const SizedBox(height: 48),
                FilledButton.icon(
                  key: _anchorKey,
                  onPressed: _busy ? null : _onPickPressed,
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_calendar),
                  label: Text(
                    _busy ? 'Saving…' : 'Pick date & time',
                    style: theme.textTheme.titleMedium,
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
