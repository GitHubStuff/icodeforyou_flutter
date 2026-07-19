import 'package:analog_clock_widget/src/analog_clock.dart'
    show ClockFaceStyle, HandStyle;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color, immutable;

/// Describes how a clock is styled.
@immutable
class ClockStyle extends Equatable {
  /// Constructor
  const ClockStyle({
    this.faceColor,
    this.borderColor,
    this.hourHandColor,
    this.minuteHandColor,
    this.secondHandColor,
    this.showNumbers = true,
    this.showSecondHand = true,
    this.faceStyle = ClockFaceStyle.classic,
    this.handStyle = HandStyle.traditional,
  });

  /// The background color of the clock face.
  final Color? faceColor;

  /// The color of the clock border and tick marks.
  final Color? borderColor;

  /// The color of the hour hand.
  final Color? hourHandColor;

  /// The color of the minute hand.
  final Color? minuteHandColor;

  /// The color of the second hand.
  final Color? secondHandColor;

  /// Whether to show hour numbers (1-12) around the clock face.
  final bool showNumbers;

  /// Whether to show the second hand.
  final bool showSecondHand;

  /// The style of the clock face.
  final ClockFaceStyle faceStyle;

  /// The style of the clock hands.
  final HandStyle handStyle;

  /// Convenience default instance.
  static const ClockStyle defaultStyle = ClockStyle();

  /// Returns a copy of this style with the given fields replaced.
  ClockStyle copyWith({
    Color? faceColor,
    Color? borderColor,
    Color? hourHandColor,
    Color? minuteHandColor,
    Color? secondHandColor,
    bool? showNumbers,
    bool? showSecondHand,
    ClockFaceStyle? faceStyle,
    HandStyle? handStyle,
  }) {
    return ClockStyle(
      faceColor: faceColor ?? this.faceColor,
      borderColor: borderColor ?? this.borderColor,
      hourHandColor: hourHandColor ?? this.hourHandColor,
      minuteHandColor: minuteHandColor ?? this.minuteHandColor,
      secondHandColor: secondHandColor ?? this.secondHandColor,
      showNumbers: showNumbers ?? this.showNumbers,
      showSecondHand: showSecondHand ?? this.showSecondHand,
      faceStyle: faceStyle ?? this.faceStyle,
      handStyle: handStyle ?? this.handStyle,
    );
  }

  @override
  List<Object?> get props => [
    faceColor,
    borderColor,
    hourHandColor,
    minuteHandColor,
    secondHandColor,
    showNumbers,
    showSecondHand,
    faceStyle,
    handStyle,
  ];
}
