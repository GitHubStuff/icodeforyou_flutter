// packages/custom_widgets/lib/src/uninherited_text/uninherited_text.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// A standalone fallback message that renders correctly even when
/// [SplashFlow] is mounted above [MaterialApp] (i.e. with no inherited
/// [DefaultTextStyle], [Directionality], or [Material]).
class UninheritedText extends StatelessWidget {
  const UninheritedText(
    this.text, {
    super.key,
    this.backgroundColor = Colors.black,
    this.style = const TextStyle(
      color: Colors.redAccent,
      fontSize: 32,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w700,
    ),
  });

  final String text;
  final Color backgroundColor;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: backgroundColor,
        child: Center(
          child: DefaultTextStyle(
            style: style,
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
