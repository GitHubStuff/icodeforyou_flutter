// lib/src/infinite_scroll_picker_config.dart

// ignore_for_file: public_member_api_docs

part of 'library.dart';

/// Configuration for an [InfiniteScrollPicker].
///
/// Carries the list of [items] to scroll through, the [startingIndex] to
/// land on, an opaque [pickerId] of type [K] that round-trips through the
/// `onItemSelected` callback, and visual settings for the surrounding frame.
/// Wheel-specific visuals live on the nested [wheelConfig].
///
/// Type parameters:
/// * [T] — the item type. Each entry in [items] is a `T`, and the
///   `onItemSelected` callback delivers a `T`.
/// * [K] — the picker identifier type. Use `String` for casual identifiers,
///   or pass an enum / sealed class for type-safe routing when a single
///   handler serves multiple pickers.
@immutable
class InfiniteScrollPickerConfig<T, K> {
  const InfiniteScrollPickerConfig({
    required this.items,
    required this.pickerId,
    required this.startingIndex,
    this.wheelConfig = const InfiniteScrollWheelConfig(),
    this.frameBorderRadius = 8.0,
    this.frameHorizontalPadding = 12.0,
    this.frameVerticalPadding = 6.0,
  }) : assert(items.length > 0, 'items must not be empty'),
       assert(
         startingIndex >= 0,
         'startingIndex ($startingIndex) must be >= 0',
       ),
       assert(
         startingIndex < items.length,
         'startingIndex ($startingIndex) must be < items.length '
         '(${items.length})',
       ),
       assert(
         frameBorderRadius >= 0,
         'frameBorderRadius ($frameBorderRadius) must be >= 0',
       ),
       assert(
         frameHorizontalPadding >= 0,
         'frameHorizontalPadding ($frameHorizontalPadding) must be >= 0',
       ),
       assert(
         frameVerticalPadding >= 0,
         'frameVerticalPadding ($frameVerticalPadding) must be >= 0',
       );

  /// Items the wheel cycles through. Must be non-empty.
  final List<T> items;

  /// An opaque identifier returned with the selection callback so a single
  /// handler can disambiguate between multiple pickers. Generic over [K]
  /// so consumers can use `String`, an enum, or any other type.
  final K pickerId;

  /// Index in [items] to land on when the picker first builds.
  final int startingIndex;

  /// Visual and behavioral configuration for the wheel itself.
  final InfiniteScrollWheelConfig wheelConfig;

  /// Corner radius of the outer frame surrounding the label and wheel.
  final double frameBorderRadius;

  /// Horizontal padding inside the outer frame.
  final double frameHorizontalPadding;

  /// Vertical padding inside the outer frame.
  final double frameVerticalPadding;

  /// Multiplier used to seed the initial wheel offset for infinite scrolling.
  ///
  /// The actual seed is:
  ///       `items.length * _infiniteWrapMultiplier + startingIndex`,
  /// which guarantees the seed is always congruent to [startingIndex]
  /// modulo `items.length` — independent of list size. The multiplier is
  /// chosen large enough that no realistic user will ever scroll out of the
  /// safe range.
  static const int _infiniteWrapMultiplier = 10000;

  /// Computes the seed offset for the wheel's `FixedExtentScrollController`.
  /// Used internally by the picker; exposed `@visibleForTesting` so tests
  /// can verify wrap behavior without scrolling thousands of items.
  @visibleForTesting
  int get initialWheelOffset =>
      (items.length * _infiniteWrapMultiplier) + startingIndex;

  /// Returns a copy with the given fields replaced.
  ///
  /// Useful inside `didUpdateWidget` flows or Cubit state when the consumer
  /// wants to nudge a single field without reassembling the whole config.
  InfiniteScrollPickerConfig<T, K> copyWith({
    List<T>? items,
    K? pickerId,
    int? startingIndex,
    InfiniteScrollWheelConfig? wheelConfig,
    double? frameBorderRadius,
    double? frameHorizontalPadding,
    double? frameVerticalPadding,
  }) {
    return InfiniteScrollPickerConfig<T, K>(
      items: items ?? this.items,
      pickerId: pickerId ?? this.pickerId,
      startingIndex: startingIndex ?? this.startingIndex,
      wheelConfig: wheelConfig ?? this.wheelConfig,
      frameBorderRadius: frameBorderRadius ?? this.frameBorderRadius,
      frameHorizontalPadding:
          frameHorizontalPadding ?? this.frameHorizontalPadding,
      frameVerticalPadding: frameVerticalPadding ?? this.frameVerticalPadding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfiniteScrollPickerConfig<T, K> &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items) &&
          pickerId == other.pickerId &&
          startingIndex == other.startingIndex &&
          wheelConfig == other.wheelConfig &&
          frameBorderRadius == other.frameBorderRadius &&
          frameHorizontalPadding == other.frameHorizontalPadding &&
          frameVerticalPadding == other.frameVerticalPadding;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    pickerId,
    startingIndex,
    wheelConfig,
    frameBorderRadius,
    frameHorizontalPadding,
    frameVerticalPadding,
  );

  static bool _listEquals<E>(List<E> a, List<E> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
