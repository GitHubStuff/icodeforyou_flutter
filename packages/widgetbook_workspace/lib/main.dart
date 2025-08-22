import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// This file does not exist yet,
// it will be generated in the next step
import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // The [directories] variable does not exist yet,
      // it will be generated in the next step
      directories: directories,
      addons: [
        // 📱 Viewport/Device Support (Correct type: ViewportData)
        // Screen sizes (replaces DeviceAddon/DeviceFrameAddon)
        ViewportAddon([
          ViewportData(
            name: 'iPhone 13',
            width: 390,
            height: 844,
            pixelRatio: 3.0,
            platform: TargetPlatform.iOS,
            safeAreas: EdgeInsets.only(top: 47, bottom: 34),
          ),
          ViewportData(
            name: 'Desktop',
            width: 1440,
            height: 900,
            pixelRatio: 2.0,
            platform: TargetPlatform.macOS,
            safeAreas: EdgeInsets.zero,
          ),
        ]),

        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(
              name: 'Light Theme',
              data: ThemeData.light(useMaterial3: true),
            ),
            WidgetbookTheme(
              name: 'Dark Theme',
              data: ThemeData.dark(useMaterial3: true),
            ),
          ],
          themeBuilder: (context, theme, child) {
            return Builder(
              builder: (context) {
                return Theme(
                  data: theme,
                  child: Material(
                    color: theme.scaffoldBackgroundColor,
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
