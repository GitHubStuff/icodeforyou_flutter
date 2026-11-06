// packages/place_holder_widget/lib/src/place_holder_screen.dart

import 'package:flutter/material.dart';
import 'package:place_holder_widget/place_holder_widget.dart'
    show PlaceholderWidget;

///
class PlaceHolderScreen extends StatelessWidget {
  ///
  const PlaceHolderScreen({super.key, this.header, this.body});

  ///
  factory PlaceHolderScreen.withString(String string, {Widget? body}) {
    final textWidget = Text(
      string,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurpleAccent,
      ),
    );
    return PlaceHolderScreen(
      header: textWidget,
      body: body,
    );
  }

  /// Used by GoRouter
  static String get route => '/menu_bar_screen';

  final Widget? header;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlaceholderWidget(
        header: header,
        body: body,
      ),
    );
  }
}
