// programs/creature_comforts/lib/src/home/home_screen.dart
import 'package:creature_comforts/src/home/widgets/fed_button.dart';
import 'package:creature_comforts/src/last_fed/last_fed_cubit.dart';
import 'package:creature_comforts/src/last_fed/last_fed_state.dart';
import 'package:creature_comforts/src/widgets/last_fed_display.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show CrittersStatus;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Home screen — the primary view for recording a feeding.
///
/// Composes three children vertically:
///
/// 1. [_PetImage] — pet image; swaps between `assets/critters.png` and
///    `assets/dead.png` based on [CrittersStatus] selected from the
///    app-wide `LastFedCubit`.
/// 2. [LastFedDisplay] — shared timestamp + elapsed widget, also used
///    on the Edit screen.
/// 3. [FedButton] — the big round "FED" button that records the
///    current moment as the most recent feeding.
///
/// Owns no state. Reads everything time-related from the `LastFedCubit`
/// provided by `app.dart`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PetImage(),
                SizedBox(height: 32),
                LastFedDisplay(),
                SizedBox(height: 48),
                FedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asset path for each [CrittersStatus].
///
/// Keeping the mapping in the home screen rather than on the enum
/// keeps presentation concerns out of the domain layer
/// (`creature_comforts_service`); a future per-pet skin would swap
/// this map without touching the enum.
const Map<CrittersStatus, String> _kPetAssetByStatus = {
  CrittersStatus.alive: 'assets/critters.png',
  CrittersStatus.dead: 'assets/dead.png',
};

/// Pet image, switched by [CrittersStatus].
///
/// Subscribes to `LastFedCubit` via [BlocSelector] selecting only the
/// status slice — rebuilds happen on alive↔dead transitions only,
/// never on minute ticks (those drive [LastFedDisplay] alone).
///
/// While the cubit is in [LastFedInitializing] or [LastFedFailureState]
/// the image shows the alive asset; surfacing failure copy under the
/// pet would duplicate what [LastFedDisplay] already renders.
class _PetImage extends StatelessWidget {
  const _PetImage();

  static const double _size = 160.0;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LastFedCubit, LastFedState, CrittersStatus>(
      selector: _selectStatus,
      builder: (context, status) {
        final assetPath =
            _kPetAssetByStatus[status] ??
            _kPetAssetByStatus[CrittersStatus.alive]!;
        return SizedBox(
          width: _size,
          height: _size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) =>
                  const _PetImagePlaceholder(size: _size),
            ),
          ),
        );
      },
    );
  }

  /// Maps the full [LastFedState] to the slice [_PetImage] cares about.
  ///
  /// Pulled out as a static function (rather than inlined into the
  /// builder) so [BlocSelector]'s memoisation can compare the result
  /// across rebuilds without allocating a new closure each frame.
  static CrittersStatus _selectStatus(LastFedState state) {
    return switch (state) {
      LastFedInitializing() => CrittersStatus.alive,
      LastFedFailureState() => CrittersStatus.alive,
      LastFedReady(:final status) => status,
    };
  }
}

/// Visual placeholder shown when [Image.asset] fails to load — typically
/// because the asset is missing on a fresh checkout. Lets the program
/// run before art assets are committed; once the asset is in place the
/// placeholder vanishes automatically.
class _PetImagePlaceholder extends StatelessWidget {
  const _PetImagePlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.pets,
        size: size * 0.4,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
