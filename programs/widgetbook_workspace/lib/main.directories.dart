// lib/main.directories.dart

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_workspace/packages/adaptive_modal/adaptive_modal.usecase.dart'
    as adaptive_modal;
import 'package:widgetbook_workspace/packages/analog_clock_widget/analog_clock_widget.usecase.dart'
    as analog_clock_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_widgets.usecase.dart'
    as animated_widgets;
import 'package:widgetbook_workspace/packages/edittext_popover/edittext_popover.usecase.dart'
    as edittext_popover;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecase.dart'
    as random_color_generator;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/scrolling_datetime_pickers.usecase.dart'
    as scrolling_datetime_pickers;
import 'package:widgetbook_workspace/packages/settings_widget/settings_widget.usecase.dart'
    as settings_widget;
import 'package:widgetbook_workspace/packages/since_when_widgets/since_when_widgets.usecase.dart'
    as since_when_widgets;
import 'package:widgetbook_workspace/packages/sqlite_viewer/sqlite_viewer.usecase.dart'
    as sqlite_viewer;
import 'package:widgetbook_workspace/packages/step_slider_package/step_slider_package.usecase.dart'
    as step_slider_package;
import 'package:widgetbook_workspace/packages/tag_chip/tag_chip.usecase.dart'
    as tag_chip;

final directories = <WidgetbookNode>[
  // ── Flat components ────────────────────────────────────────────────────────
  WidgetbookComponent(
    name: 'AdaptiveModalController',
    useCases: [
      WidgetbookUseCase(
        name: 'Custom Close Icon',
        builder: adaptive_modal.adaptiveModalCustomIcon,
      ),
      WidgetbookUseCase(
        name: 'Default',
        builder: adaptive_modal.adaptiveModalDefault,
      ),
      WidgetbookUseCase(
        name: 'No Barrier',
        builder: adaptive_modal.adaptiveModalNoBarrier,
      ),
      WidgetbookUseCase(
        name: 'Return Value',
        builder: adaptive_modal.adaptiveModalReturnValue,
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AnalogClock',
    useCases: [
      WidgetbookUseCase(
        name: 'Classic Face',
        builder: analog_clock_widget.analogClockClassic,
      ),
      WidgetbookUseCase(
        name: 'Default',
        builder: analog_clock_widget.analogClockDefault,
      ),
      WidgetbookUseCase(
        name: 'Minimal Face',
        builder: analog_clock_widget.analogClockMinimal,
      ),
      WidgetbookUseCase(
        name: 'Modern Face',
        builder: analog_clock_widget.analogClockModern,
      ),
      WidgetbookUseCase(
        name: 'Modern Hands',
        builder: analog_clock_widget.analogClockModernHands,
      ),
      WidgetbookUseCase(
        name: 'No Numbers',
        builder: analog_clock_widget.analogClockNoNumbers,
      ),
      WidgetbookUseCase(
        name: 'No Second Hand',
        builder: analog_clock_widget.analogClockNoSecondHand,
      ),
      WidgetbookUseCase(
        name: 'Sleek Hands',
        builder: analog_clock_widget.analogClockSleekHands,
      ),
      WidgetbookUseCase(
        name: 'Timezone',
        builder: analog_clock_widget.analogClockTimezone,
      ),
      WidgetbookUseCase(
        name: 'Traditional Hands',
        builder: analog_clock_widget.analogClockTraditionalHands,
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'EditorTextField',
    useCases: [
      WidgetbookUseCase(
        name: 'EditorTextField',
        builder: edittext_popover.editorTextFieldUseCase,
      ),
      WidgetbookUseCase(
        name: 'showEditor',
        builder: edittext_popover.showEditorUseCase,
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'RandomColorGenerator',
    useCases: [
      WidgetbookUseCase(
        name: 'contrastingTextColor',
        builder: random_color_generator.randomColorGeneratorContrast,
      ),
      WidgetbookUseCase(
        name: 'generate',
        builder: random_color_generator.randomColorGeneratorGenerate,
      ),
      WidgetbookUseCase(
        name: 'toHex & fromHex',
        builder: random_color_generator.randomColorGeneratorHex,
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'SettingsWidget',
    useCases: [
      WidgetbookUseCase(
        name: 'Custom Title',
        builder: settings_widget.settingsWidgetCustomTitle,
      ),
      WidgetbookUseCase(
        name: 'Default',
        builder: settings_widget.settingsWidgetDefault,
      ),
      WidgetbookUseCase(
        name: 'Force Phone Layout',
        builder: settings_widget.settingsWidgetPhone,
      ),
      WidgetbookUseCase(
        name: 'Force Tablet Layout',
        builder: settings_widget.settingsWidgetTablet,
      ),
      WidgetbookUseCase(
        name: 'Many Entries (Scrollable)',
        builder: settings_widget.settingsWidgetScrollable,
      ),
      WidgetbookUseCase(
        name: 'Single Entry',
        builder: settings_widget.settingsWidgetSingleEntry,
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'StepSlider',
    useCases: [
      WidgetbookUseCase(
        name: 'Custom Colours',
        builder: step_slider_package.stepSliderCustomColours,
      ),
      WidgetbookUseCase(
        name: 'Default',
        builder: step_slider_package.stepSliderDefault,
      ),
      WidgetbookUseCase(
        name: 'Haptic Feedback',
        builder: step_slider_package.stepSliderHaptic,
      ),
      WidgetbookUseCase(
        name: 'Step Sizes',
        builder: step_slider_package.stepSliderStepSizes,
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'TagChip',
    useCases: [
      WidgetbookUseCase(
        name: 'Interactive',
        builder: tag_chip.tagChipInteractive,
      ),
      WidgetbookUseCase(
        name: 'States',
        builder: tag_chip.tagChipStates,
      ),
    ],
  ),
  // ── Folders ────────────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'animated_checkbox',
    children: [
      WidgetbookComponent(
        name: 'AnimatedCheckbox',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets.animatedCheckboxDefault,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'grow_and_fade_widget',
    children: [
      WidgetbookComponent(
        name: 'GrowAndFadeWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets.growAndFadeWidgetDefault,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'grow_widget',
    children: [
      WidgetbookComponent(
        name: 'GrowWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets.growWidgetDefault,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'presentation',
    children: [
      WidgetbookFolder(
        name: 'widgets',
        children: [
          WidgetbookComponent(
            name: 'ScrollingDatePicker',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder:
                    scrolling_datetime_pickers.scrollingDatePickerDefault,
              ),
              WidgetbookUseCase(
                name: 'Glow Dividers',
                builder:
                    scrolling_datetime_pickers.scrollingDatePickerGlowDividers,
              ),
            ],
          ),
          WidgetbookComponent(
            name: 'ScrollingTimePicker',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder:
                    scrolling_datetime_pickers.scrollingTimePickerDefault,
              ),
            ],
          ),
          WidgetbookFolder(
            name: 'datetime_popover',
            children: [
              WidgetbookComponent(
                name: 'DateTimePickerField',
                useCases: [
                  WidgetbookUseCase(
                    name: 'Date & Time',
                    builder: scrolling_datetime_pickers
                        .dateTimePickerFieldDateTime,
                  ),
                  WidgetbookUseCase(
                    name: 'Date Only',
                    builder: scrolling_datetime_pickers
                        .dateTimePickerFieldDateOnly,
                  ),
                  WidgetbookUseCase(
                    name: 'Time Only',
                    builder: scrolling_datetime_pickers
                        .dateTimePickerFieldTimeOnly,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'since_when_widgets',
    children: [
      WidgetbookFolder(
        name: 'counted_text_field',
        children: [
          WidgetbookComponent(
            name: 'CountedTextField',
            useCases: [
              WidgetbookUseCase(
                name: 'Caption',
                builder: since_when_widgets.countedTextFieldCaption,
              ),
              WidgetbookUseCase(
                name: 'Custom Clear Widget',
                builder: since_when_widgets.countedTextFieldCustomClear,
              ),
              WidgetbookUseCase(
                name: 'Default',
                builder: since_when_widgets.countedTextFieldDefault,
              ),
              WidgetbookUseCase(
                name: 'Hint Text',
                builder: since_when_widgets.countedTextFieldHintText,
              ),
              WidgetbookUseCase(
                name: 'Live Output',
                builder: since_when_widgets.countedTextFieldLiveOutput,
              ),
              WidgetbookUseCase(
                name: 'RTL',
                builder: since_when_widgets.countedTextFieldRtl,
              ),
              WidgetbookUseCase(
                name: 'Truncation',
                builder: since_when_widgets.countedTextFieldTruncation,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'widgets',
    children: [
      WidgetbookComponent(
        name: 'SqliteViewerPage',
        useCases: [
          WidgetbookUseCase(
            name: 'Connecting',
            builder: sqlite_viewer.sqliteViewerConnecting,
          ),
          WidgetbookUseCase(
            name: 'Connection Failed',
            builder: sqlite_viewer.sqliteViewerConnectionFailed,
          ),
          WidgetbookUseCase(
            name: 'Metadata Loaded',
            builder: sqlite_viewer.sqliteViewerMetadataLoaded,
          ),
          WidgetbookUseCase(
            name: 'Query Failed',
            builder: sqlite_viewer.sqliteViewerQueryFailed,
          ),
          WidgetbookUseCase(
            name: 'Query Result',
            builder: sqlite_viewer.sqliteViewerQueryResult,
          ),
          WidgetbookUseCase(
            name: 'Table Detail',
            builder: sqlite_viewer.sqliteViewerTableDetail,
          ),
        ],
      ),
    ],
  ),
];
