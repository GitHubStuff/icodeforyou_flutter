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
import 'package:widgetbook_workspace/packages/adaptive_modal/adaptive_modal.usecase.dart'
    as _widgetbook_workspace_packages_adaptive_modal_adaptive_modal_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/analog_clock_widget.dart'
    as _widgetbook_workspace_packages_analog_clock_widget_analog_clock_widget;
import 'package:widgetbook_workspace/packages/edittext_popover/edittext_popover.usecase.dart'
    as _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase;
import 'package:widgetbook_workspace/packages/extensions/date_time_ext/datetime_delta_stories.dart'
    as _widgetbook_workspace_packages_extensions_date_time_ext_datetime_delta_stories;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecases.dart'
    as _widgetbook_workspace_packages_random_color_generator_random_color_generator_usecases;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/scrolling_datetime_pickers_widgetbook.dart'
    as _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/sqlite_viewer.usecase.dart'
    as _widgetbook_workspace_packages_sqlite_viewer_sqlite_viewer_usecase;
import 'package:widgetbook_workspace/packages/startup_package/startup_package.usecase.dart'
    as _widgetbook_workspace_packages_startup_package_startup_package_usecase;
import 'package:widgetbook_workspace/packages/step_slider_package/step_slider_package.usecase.dart'
    as _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase;

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
    name: 'EditorTextField',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Custom Barrier Color',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .editorTextFieldCustomBarrier,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Custom Buttons',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .editorTextFieldCustomButtons,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Custom Styling',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .editorTextFieldCustomStyling,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .editorTextFieldDefault,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Interactive Playground',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .editorTextFieldPlayground,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Multiline Content',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .editorTextFieldMultiline,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Show Editor Function',
        builder:
            _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase
                .showEditorDemo,
      ),
    ],
  ),
  _widgetbook.WidgetbookComponent(
    name: 'StepSlider',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Decimal Precision',
        builder:
            _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase
                .buildStepSliderDecimal,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase
                .buildStepSliderDefault,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Discrete Steps',
        builder:
            _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase
                .buildStepSliderDiscrete,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Haptic Feedback Comparison',
        builder:
            _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase
                .buildStepSliderHapticComparison,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Multiple Sliders',
        builder:
            _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase
                .buildStepSliderMultiple,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'With Custom Colors',
        builder:
            _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase
                .buildStepSliderCustomColors,
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
    name: 'packages',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'adaptive_modal',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AdaptiveModal',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Custom Close Icon',
                builder:
                    _widgetbook_workspace_packages_adaptive_modal_adaptive_modal_usecase
                        .adaptiveModalCustomIcon,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_packages_adaptive_modal_adaptive_modal_usecase
                        .adaptiveModalDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'No Barrier',
                builder:
                    _widgetbook_workspace_packages_adaptive_modal_adaptive_modal_usecase
                        .adaptiveModalNoBarrier,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Return Value',
                builder:
                    _widgetbook_workspace_packages_adaptive_modal_adaptive_modal_usecase
                        .adaptiveModalReturnValue,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'random_color_generator',
        children: [
          _widgetbook.WidgetbookComponent(
            name: '_ContrastShowcase',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contrasting Text Color',
                builder:
                    _widgetbook_workspace_packages_random_color_generator_random_color_generator_usecases
                        .buildContrastUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: '_FromHexShowcase',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Manual Hex Input',
                builder:
                    _widgetbook_workspace_packages_random_color_generator_random_color_generator_usecases
                        .buildFromHexUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: '_GenerateShowcase',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Random Color Grid',
                builder:
                    _widgetbook_workspace_packages_random_color_generator_random_color_generator_usecases
                        .buildGenerateUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: '_HexRoundtripShowcase',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Hex Roundtrip',
                builder:
                    _widgetbook_workspace_packages_random_color_generator_random_color_generator_usecases
                        .buildHexRoundtripUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'startup_package',
        children: [
          _widgetbook.WidgetbookComponent(
            name: '_DemoSplashScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Splash — task failure',
                builder:
                    _widgetbook_workspace_packages_startup_package_startup_package_usecase
                        .buildSplashErrorUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Splash — tasks finish after animation',
                builder:
                    _widgetbook_workspace_packages_startup_package_startup_package_usecase
                        .buildSplashWithLoadingUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Splash — tasks finish before animation',
                builder:
                    _widgetbook_workspace_packages_startup_package_startup_package_usecase
                        .buildSplashTasksFirstUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'presentation',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ScrollingDatePicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                        .buildScrollingDatePickerDefaultCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive Demo',
                builder:
                    _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                        .buildScrollingDatePickerInteractiveCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ScrollingTimePicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                        .buildScrollingTimePickerDefaultCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive Demo',
                builder:
                    _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                        .buildScrollingTimePickerInteractiveCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'datetime_popover',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'DateTimePickerPopover',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Date Only Mode',
                    builder:
                        _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                            .buildDateTimePopoverDateOnlyModeCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'DateTime Mode',
                    builder:
                        _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                            .buildDateTimePopoverDateTimeModeCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'Light & Dark Theme',
                    builder:
                        _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                            .buildDateTimePopoverThemeShowcaseCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'Time Only Mode',
                    builder:
                        _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook
                            .buildDateTimePopoverTimeOnlyModeCase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'DisplayQueryWidget',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Dark Theme',
            builder:
                _widgetbook_workspace_packages_sqlite_viewer_sqlite_viewer_usecase
                    .buildDisplayQueryWidgetDark,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder:
                _widgetbook_workspace_packages_sqlite_viewer_sqlite_viewer_usecase
                    .buildDisplayQueryWidgetDefault,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Empty State',
            builder:
                _widgetbook_workspace_packages_sqlite_viewer_sqlite_viewer_usecase
                    .buildDisplayQueryWidgetEmpty,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Many Columns',
            builder:
                _widgetbook_workspace_packages_sqlite_viewer_sqlite_viewer_usecase
                    .buildDisplayQueryWidgetManyColumns,
          ),
        ],
      ),
    ],
  ),
];
