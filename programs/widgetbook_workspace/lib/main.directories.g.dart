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
import 'package:widgetbook_workspace/packages/animated_checkbox_widget/animated_checkbox_widgetbook.dart'
    as _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook;
import 'package:widgetbook_workspace/packages/edittext_popover/edittext_popover.usecase.dart'
    as _widgetbook_workspace_packages_edittext_popover_edittext_popover_usecase;
import 'package:widgetbook_workspace/packages/extensions/date_time_ext/datetime_delta_stories.dart'
    as _widgetbook_workspace_packages_extensions_date_time_ext_datetime_delta_stories;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/scrolling_datetime_pickers_widgetbook.dart'
    as _widgetbook_workspace_packages_scrolling_datetime_pickers_scrolling_datetime_pickers_widgetbook;
import 'package:widgetbook_workspace/packages/since_when/since_when.usecase.dart'
    as _widgetbook_workspace_packages_since_when_since_when_usecase;
import 'package:widgetbook_workspace/packages/since_when/since_when_database.usecase.dart'
    as _widgetbook_workspace_packages_since_when_since_when_database_usecase;
import 'package:widgetbook_workspace/packages/sqlite_viewer/sqlite_viewer.usecase.dart'
    as _widgetbook_workspace_packages_sqlite_viewer_sqlite_viewer_usecase;
import 'package:widgetbook_workspace/packages/step_slider_package/step_slider_package.usecase.dart'
    as _widgetbook_workspace_packages_step_slider_package_step_slider_package_usecase;
import 'package:widgetbook_workspace/packages/theme_package/theme_package.usecase.dart'
    as _widgetbook_workspace_packages_theme_package_theme_package_usecase;

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
        name: 'Animation Curves',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxCurvesCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Custom Shapes',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxCustomShapesCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxDefaultCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Dissolve Effect',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxDissolveCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Extreme Shapes',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxExtremeShapesCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Interactive Demo',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxInteractiveCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Performance Test',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxPerformanceCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Platform Optimized',
        builder:
            _widgetbook_workspace_packages_animated_checkbox_widget_animated_checkbox_widgetbook
                .buildAnimatedCheckboxPlatformCase,
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
    name: 'SinceWhenDatabase',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Main Table Detail',
        builder:
            _widgetbook_workspace_packages_since_when_since_when_database_usecase
                .mainTableDetail,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Pragma Data',
        builder:
            _widgetbook_workspace_packages_since_when_since_when_database_usecase
                .pragmaDataView,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'SqliteViewer Integration',
        builder:
            _widgetbook_workspace_packages_since_when_since_when_database_usecase
                .sqliteViewerIntegration,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Tag Analytics',
        builder:
            _widgetbook_workspace_packages_since_when_since_when_database_usecase
                .tagAnalytics,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Tags Table View',
        builder:
            _widgetbook_workspace_packages_since_when_since_when_database_usecase
                .tagsTableView,
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
  _widgetbook.WidgetbookComponent(
    name: 'ThemeBuilder',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_theme_package_theme_package_usecase
                .buildThemeBuilderUseCase,
      ),
    ],
  ),
  _widgetbook.WidgetbookComponent(
    name: 'ThemeSelectorWidget',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder:
            _widgetbook_workspace_packages_theme_package_theme_package_usecase
                .buildThemeSelectorWidgetUseCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'In Settings Page',
        builder:
            _widgetbook_workspace_packages_theme_package_theme_package_usecase
                .buildThemeSelectorInSettingsUseCase,
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
    name: 'domain',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'SinceWhenFailure',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Failure Types',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .sinceWhenFailures,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SinceWhenRecord',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Hierarchical Records',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .sinceWhenHierarchical,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Interactive Playground',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .sinceWhenPlayground,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Record Creation Demo',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .sinceWhenRecordCreation,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Tags Demo',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .sinceWhenTags,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'TableInfo',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Table Info',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .sinceWhenTableInfo,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'TagMatchMode',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'TagMatchMode',
            builder:
                _widgetbook_workspace_packages_since_when_since_when_usecase
                    .tagMatchModeDemo,
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
