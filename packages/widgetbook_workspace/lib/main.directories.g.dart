// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/packages/analog_clock_widget/analog_clock_widget.dart'
    as _widgetbook_workspace_packages_analog_clock_widget_analog_clock_widget;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookComponent(
    name: 'AnalogClock',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_analog_clock_widget_analog_clock_widget
                .buildAnalogClockCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Full features',
        builder:
            _widgetbook_workspace_packages_analog_clock_widget_analog_clock_widget
                .buildAnalogClockDarkCase,
      ),
    ],
  ),
];
