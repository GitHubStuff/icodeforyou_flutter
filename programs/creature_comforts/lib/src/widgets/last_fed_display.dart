// programs/creature_comforts/lib/src/widgets/last_fed_display.dart
import 'dart:async';

import 'package:creature_comforts/descriptors/last_fed_descriptor.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show LastFedFailure, LastFedService;
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:intl/intl.dart';
import 'package:service_locator/service_locator.dart';

/// Shared display block for Home and Edit screens.
///
/// Shows two pieces of information about the most recent feeding:
///
/// 1. The absolute timestamp ("May 5, 2026 at 2:43 PM"), localised via
///    [DateFormat].
/// 2. The elapsed time since that timestamp ("3h 22m ago") — but only
///    while the elapsed is under one week. Beyond that, the line
///    switches to a gallows-humor message about the unfortunate state
///    of the household pets, on the theory that anything more than a
///    week without a feeding is a problem the user is going to want
///    flagged unambiguously rather than expressed in calendar units.
///
/// Subscribes to [LastFedService.watch] for live propagation of writes
/// from any of the household's signed-in users — feeding the pet on one
/// device updates this widget on all the others within ~1 second.
///
/// Ticks an internal timer every minute so the elapsed display advances
/// without requiring a backend update. The minute cadence matches the
/// finest unit shown in the elapsed text.
class LastFedDisplay extends StatefulWidget {
  const LastFedDisplay({super.key});

  @override
  State<LastFedDisplay> createState() => _LastFedDisplayState();
}

class _LastFedDisplayState extends State<LastFedDisplay> {
  StreamSubscription<Either<LastFedFailure, DateTime>>? _sub;
  Timer? _tick;
  Either<LastFedFailure, DateTime>? _latest;

  @override
  void initState() {
    super.initState();
    final service = ServiceRegistry.R.getSync<LastFedService>(
      LastFedServiceDescriptor.kName,
    );
    _sub = service.watch().listen((event) {
      if (!mounted) return;
      setState(() => _latest = event);
    });
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latest = _latest;
    if (latest == null) {
      return const _LoadingBlock();
    }
    return latest.match(
      (failure) => _FailureBlock(failure: failure),
      (when) => _DisplayBlock(when: when),
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

/// The success render: absolute timestamp + elapsed line.
///
/// The elapsed line takes one of two shapes:
///
/// - Under [_kCap]: a formatted "Xd Yh Zm ago" string assembled from
///   the raw `Duration` between now and the feeding timestamp.
/// - Past [_kCap]: the gallows-humor message [_kCrittersAreDeadMessage],
///   which doubles as a strong visual cue that the situation has gone
///   past polite reminders.
class _DisplayBlock extends StatelessWidget {
  const _DisplayBlock({required this.when});

  final DateTime when;

  /// Maximum elapsed window we render with the time-delta line.
  static const Duration _kCap = Duration(days: 7);

  /// Replacement text shown when elapsed exceeds [_kCap].
  static const String _kCrittersAreDeadMessage = 'The Critters Are Dead';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = when.toLocal();
    final absolute = DateFormat.yMMMMd().add_jm().format(local);
    final elapsed = DateTime.now().toUtc().difference(when.toUtc());

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
        if (elapsed > _kCap)
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
            _formatElapsed(elapsed),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  /// Renders [elapsed] (guaranteed < 7 days at this call site) as a
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
  /// units are dropped. Two-decimal precision (`2d 6h` rather than
  /// `2d 6h 14m`) keeps the line readable; the cadence is "minute" via
  /// the 1-minute timer in [_LastFedDisplayState], so per-second drift
  /// is invisible anyway.
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
