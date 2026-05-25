// programs/creature_comforts/lib/src/home/widgets/fed_button.dart
import 'package:creature_comforts/descriptors/last_fed_descriptor.dart';
import 'package:creature_comforts/src/haptics/haptics_cubit.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart' show LastFedService;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart';

/// The big "FED" button that records the current moment as the most
/// recent feeding.
///
/// Calls [LastFedService.update] with no `occurredAt` argument so the
/// service uses `DateTime.now().toUtc()`. The Firestore `snapshots()`
/// stream then propagates the new value to every subscriber, including
/// the [LastFedDisplay] sitting just above this button on the Home
/// screen — the elapsed counter resets immediately.
///
/// Haptic feedback fires on every tap at the user's chosen
/// [HapticIntensity], read from [HapticsCubit].
///
/// Visual states:
/// - Idle: filled rounded button with "FED" label.
/// - In-flight: button disabled, spinner replaces the label.
/// - Failure: snackbar with the failure message; button re-enables.
/// - Success: no toast — the elapsed display resetting is the
///   acknowledgement.
class FedButton extends StatefulWidget {
  const FedButton({super.key});

  @override
  State<FedButton> createState() => _FedButtonState();
}

class _FedButtonState extends State<FedButton> {
  bool _busy = false;

  Future<void> _onPressed() async {
    context.read<HapticsCubit>().tap();
    setState(() => _busy = true);

    final service = ServiceRegistry.R
        .getSync<LastFedService>(LastFedServiceDescriptor.kName);
    final result = await service.update();

    if (!mounted) return;
    setState(() => _busy = false);

    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        // Success path is silent — the LastFedDisplay above resets,
        // which is the visible acknowledgement of the write.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 200,
      height: 200,
      child: FilledButton(
        onPressed: _busy ? null : _onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: _busy
            ? const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 4),
              )
            : Text(
                'FED',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
