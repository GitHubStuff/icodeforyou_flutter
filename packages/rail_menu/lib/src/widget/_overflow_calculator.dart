// packages/rail_menu/lib/src/widget/_overflow_calculator.dart

part of '_internal.dart';

/// The result of an overflow calculation.
class _OverflowResult {
  const _OverflowResult({
    required this.visibleCount,
    required this.hasOverflow,
  });

  final int visibleCount;
  final bool hasOverflow;
}

/// Calculates how many items fit within a given extent.
///
/// When [limit] is provided, caps visible items at [limit - 1] and forces
/// the More button regardless of available space.
/// Reserves one slot for the More button when overflow is detected.
class _OverflowCalculator {
  const _OverflowCalculator();

  _OverflowResult calculate({
    required int itemCount,
    required double itemExtent,
    required double availableExtent,
    int? limit,
  }) {
    if (limit != null) return _applyLimit(itemCount: itemCount, limit: limit);
    return _applyPixelFit(
      itemCount: itemCount,
      itemExtent: itemExtent,
      availableExtent: availableExtent,
    );
  }

  _OverflowResult _applyLimit({
    required int itemCount,
    required int limit,
  }) {
    final visibleCount = (limit - 1).clamp(0, itemCount);
    return _OverflowResult(
      visibleCount: visibleCount,
      hasOverflow: itemCount > visibleCount,
    );
  }

  _OverflowResult _applyPixelFit({
    required int itemCount,
    required double itemExtent,
    required double availableExtent,
  }) {
    final maxFit = (availableExtent / itemExtent).floor();
    if (itemCount <= maxFit) {
      return _OverflowResult(visibleCount: itemCount, hasOverflow: false);
    }
    return _OverflowResult(
      visibleCount: (maxFit - 1).clamp(0, itemCount),
      hasOverflow: true,
    );
  }
}
