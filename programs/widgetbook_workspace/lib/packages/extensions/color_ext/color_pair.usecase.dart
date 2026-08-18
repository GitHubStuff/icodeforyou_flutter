// programs/widgetbook_workspace/lib/packages/extensions/color_ext/color_pair.usecase.dart

import 'package:extensions/extensions.dart' show ColorPair;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Interactive', type: ColorPair)
Widget buildColorPairUseCase(BuildContext context) {
  // 1. Define Knobs to allow users to change colors in the Widgetbook UI
  final lightColor = context.knobs.color(
    label: 'Light Theme Color',
    initialValue: Colors.grey.shade200,
  );

  final darkColor = context.knobs.color(
    label: 'Dark Theme Color',
    initialValue: Colors.grey.shade800,
  );

  // 2. Instantiate the ColorPair with the knob values
  final colorPair = ColorPair(
    dark: darkColor,
    light: lightColor,
  );

  // 3. Build a widget that reacts to the Theme's brightness
  // (Assuming you have Widgetbook configured to toggle Light/Dark themes)
  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 150,
            decoration: BoxDecoration(
              // Resolves to either lightColor or darkColor based on context
              color: colorPair.current(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              colorPair.isDark(context) ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // Automatically gets the contrasting color for readable text
                color: colorPair.contrastingColor(context),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Toggle your Widgetbook theme to see the ColorPair update!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
