// programs/creature_comforts/lib/src/widgets/last_fed_display.dart
import 'package:creature_comforts/src/last_fed/last_fed_cubit.dart';
import 'package:creature_comforts/src/last_fed/last_fed_state.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show CrittersStatus, LastFedFailure;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Shared display block for Home and Edit screens.
///
/// Shows two pieces of information about the most recent feeding:
///
/// 1. The absolute timestamp ("May 5, 2026 at 2:43 PM"), localised via
///    [DateFormat].
/// 2. The elapsed time since that timestamp ("3h 22m ago") — but only
///    while the critters are [CrittersStatus.alive]. Once the rule in
///    [crittersStatusFor] flips them to [CrittersStatus.dead], the
///    line switches to a gallows-humor message, on the theory that
///    anything past the death threshold is a problem the user will
///    want flagged unambiguously rather than expressed in calendar
///    units.
///
/// Reads everything from the app-wide `LastFedCubit` (provided in
/// `app.dart`). Owns no subscription, no timer, and no service-locator
/// lookup of its own — single source of truth lives in the cubit.
class LastFedDisplay extends StatelessWidget {
  const LastFedDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LastFedCubit, LastFedState>(
      builder: (context, state) {
        return switch (state) {
          LastFedInitializing() => const _LoadingBlock(),
          LastFedFailureState(:final failure) => _FailureBlock(
            failure: failure,
          ),
          LastFedReady(:final lastFed, :final status) => _DisplayBlock(
            when: lastFed,
            status: status,
          ),
        };
      },
    );
  }
}

/// Centred spinner shown while the first stream event is in flight.
class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Inline error block shown when the stream emits a [LastFedFailure].
///
/// Stays present so transient errors are visible; the next successful
/// stream emission replaces it.
class _FailureBlock extends StatelessWidget {
  const _FailureBlock({required this.failure});

  final LastFedFailure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
          const SizedBox(height: 12),
          Text(
            failure.message,
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Replacement text shown when the critters are [CrittersStatus.dead].
const String _kCrittersAreDeadMessage = 'The Critters Are Dead';

/// The success render: absolute timestamp + elapsed line.
///
/// The elapsed line takes one of two shapes, driven by [status]
/// (delivered pre-classified by `LastFedCubit`):
///
/// - [CrittersStatus.alive] — formatted "Xd Yh Zm ago" string.
/// - [CrittersStatus.dead]  — gallows-humor [_kCrittersAreDeadMessage].
class _DisplayBlock extends StatelessWidget {
  const _DisplayBlock({required this.when, required this.status});

  final DateTime when;
  final CrittersStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = when.toLocal();
    final absolute = DateFormat.yMMMMd().add_jm().format(local);

    return Column(
      children: [
        Text(
          'Last fed',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          absolute,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        if (status == CrittersStatus.dead)
          Text(
            _kCrittersAreDeadMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            _formatElapsed(DateTime.now().toUtc().difference(when.toUtc())),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  /// Renders [elapsed] (only called while critters are alive) as a
  /// human-readable "Xd Yh Zm ago" string.
  ///
  /// Each unit is only included when non-zero, so the output reads
  /// naturally at every magnitude:
  ///
  /// - `12 minutes` ago at 12 minutes elapsed
  /// - `3h 22m ago` at 3 hours 22 minutes
  /// - `2d 6h ago` at 2 days 6 hours (minutes dropped once days appear)
  /// - `just now` for under one minute
  ///
  /// The trimming rule: once a coarser unit appears, finer-than-one-step
  /// units are dropped. Per-second drift is invisible because the
  /// cadence is "minute" — driven by `LastFedCubit`'s tick.
  String _formatElapsed(Duration elapsed) {
    if (elapsed.inMinutes < 1) return 'just now';

    final days = elapsed.inDays;
    final hours = elapsed.inHours.remainder(24);
    final minutes = elapsed.inMinutes.remainder(60);

    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    // Drop minutes once we're past one day to keep the line short.
    if (days == 0 && minutes > 0) parts.add('${minutes}m');

    if (parts.isEmpty) return 'just now';
    return '${parts.join(' ')} ago';
  }
}
