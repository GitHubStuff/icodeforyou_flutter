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
import 'package:widgetbook_workspace/packages/animated_checkbox_widget/animated_checkbox_widget.dart'
    as _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget;
import 'package:widgetbook_workspace/packages/extensions/date_time_ext/datetime_delta_stories.dart'
    as _widgetbook_workspace_packages_extensions_date_time_ext_datetime_delta_stories;
import 'package:widgetbook_workspace/packages/theme_manager/widgetbook_radiobutton_and_label.dart'
    as _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label;

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
  _widgetbook.WidgetbookComponent(
    name: 'AnimatedCheckbox',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Color Variations',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxColorsCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxDefaultCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Dissolve Effect',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxDissolveCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Interactive Demo',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxInteractiveCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Performance Test',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxPerformanceCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Platform Optimized',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxPlatformCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Size Variations',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widget
                .buildAnimatedCheckboxSizesCase,
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'datetime_ext',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'DateTimeDeltaText',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Basic Demo',
            builder:
                _widgetbook_workspace_packages_extensions_date_time_ext_datetime_delta_stories
                    .buildDateTimeDeltaTextDefault,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Full Features',
            builder:
                _widgetbook_workspace_packages_extensions_date_time_ext_datetime_delta_stories
                    .buildDateTimeDeltaTextFull,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'RadiobuttonAndLabel',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Basic String Options',
            builder:
                _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label
                    .basicStringRadioButtons,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Disabled State',
            builder:
                _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label
                    .disabledRadioButtons,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Enum Options',
            builder:
                _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label
                    .enumRadioButtons,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Integer Values',
            builder:
                _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label
                    .integerRadioButtons,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Layout Variations',
            builder:
                _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label
                    .layoutVariations,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Rich Labels',
            builder:
                _widgetbook_workspace_packages_theme_manager_widgetbook_radiobutton_and_label
                    .richLabelRadioButtons,
          ),
        ],
      ),
    ],
  ),
];
