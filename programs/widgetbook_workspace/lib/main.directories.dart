// dart format width=80
// ignore_for_file: depend_on_referenced_packages

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_workspace/packages/adaptive_modal/adaptive_modal.usecase.dart'
    as adaptive_modal;
import 'package:widgetbook_workspace/packages/analog_clock_widget/analog_clock_widget.usecase.dart'
    as analog_clock_widget;
import 'package:widgetbook_workspace/packages/animated_rail_menu/animated_rail_menu.usecase.dart'
    as animated_rail_menu;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_checkbox.usecase.dart'
    as animated_widgets_animated_checkbox;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_overlay.usecase.dart'
    as animated_widgets_animated_overlay;
import 'package:widgetbook_workspace/packages/animated_widgets/contextual_reveal.usecase.dart'
    as animated_widgets_contextual_reveal;
import 'package:widgetbook_workspace/packages/animated_widgets/fade_in_out_view.usecase.dart'
    as animated_widgets_fade_in_out_view;
import 'package:widgetbook_workspace/packages/animated_widgets/fader_widget.usecase.dart'
    as animated_widgets_fader_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_and_fade_widget.usecase.dart'
    as animated_widgets_grow_and_fade_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_widget.usecase.dart'
    as animated_widgets_grow_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/length_colored_border_field.usecase.dart'
    as animated_widgets_length_colored_border_field;
import 'package:widgetbook_workspace/packages/animated_widgets/pulse_widget.usecase.dart'
    as animated_widgets_pulse_widget;
import 'package:widgetbook_workspace/packages/edittext_popover/edittext_popover.usecase.dart'
    as edittext_popover;
import 'package:widgetbook_workspace/packages/ice_chip/ice_chip.usecase.dart'
    as ice_chip;
import 'package:widgetbook_workspace/packages/ice_chips_tray/ice_chips_tray.usecase.dart'
    as ice_chips_tray;
import 'package:widgetbook_workspace/packages/ice_chips_tray/ice_chips_tray_layout_list.usecase.dart'
    as ice_chips_tray_layout_list;
import 'package:widgetbook_workspace/packages/ice_chips_tray/ice_chips_tray_layout_row.usecase.dart'
    as ice_chips_tray_layout_row;
import 'package:widgetbook_workspace/packages/ice_chips_tray/ice_chips_tray_layout_wrap.usecase.dart'
    as ice_chips_tray_layout_wrap;
import 'package:widgetbook_workspace/packages/ice_chips_tray/ice_picker_tray.usecase.dart'
    as ice_chips_tray_ice_picker_tray;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picking;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as infinite_scroll_picking_settings;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecase.dart'
    as random_color_generator;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/scrolling_datetime_pickers.usecase.dart'
    as scrolling_datetime_pickers;
import 'package:widgetbook_workspace/packages/settings_widget/settings_widget.usecase.dart'
    as settings_widget;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_edit/tag_glossary_edit_screen_create.usecase.dart'
    as since_when_widgets_tag_glossary_edit_create;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_edit/tag_glossary_edit_screen_update.usecase.dart'
    as since_when_widgets_tag_glossary_edit_update;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_read/tag_glossary_read_view.usecase.dart'
    as since_when_widgets_tag_glossary_read;
import 'package:widgetbook_workspace/packages/slider_directional/slider_directional_horizontal.usecase.dart'
    as slider_directional_horizontal;
import 'package:widgetbook_workspace/packages/slider_directional/slider_directional_vertical.usecase.dart'
    as slider_directional_vertical;
import 'package:widgetbook_workspace/packages/slider_stepper/slider_stepper.usecase.dart'
    as slider_stepper;
import 'package:widgetbook_workspace/packages/sqlite_viewer/sqlite_viewer.usecase.dart'
    as sqlite_viewer;
import 'package:widgetbook_workspace/packages/theme_widget/theme_widget.usecase.dart'
    as theme_widget;

final directories = <WidgetbookNode>[
  // ─── adaptive_modal ──────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'adaptive_modal',
    children: [
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
    ],
  ),

  // ─── analog_clock_widget ─────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'analog_clock_widget',
    children: [
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
    ],
  ),

  // ─── animated_rail_menu ──────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'animated_rail_menu',
    children: [
      WidgetbookComponent(
        name: 'AnimatedRailMenu',
        useCases: [
          WidgetbookUseCase(
            name: 'Haptic Feedback',
            builder: animated_rail_menu.railNavigationHaptic,
          ),
          WidgetbookUseCase(
            name: 'Horizontal',
            builder: animated_rail_menu.railNavigationHorizontal,
          ),
          WidgetbookUseCase(
            name: 'Overflow — More',
            builder: animated_rail_menu.railNavigationOverflow,
          ),
          WidgetbookUseCase(
            name: 'Vertical',
            builder: animated_rail_menu.railNavigationVertical,
          ),
        ],
      ),
    ],
  ),

  // ─── animated_widgets ────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'animated_widgets',
    children: [
      WidgetbookComponent(
        name: 'AnimatedCheckbox',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_animated_checkbox.animatedCheckboxDefault,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimatedOverlay',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_animated_overlay.animatedOverlayUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ContextualReveal',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_contextual_reveal.contextualRevealDefault,
          ),
          WidgetbookUseCase(
            name: 'Simple',
            builder: animated_widgets_contextual_reveal.contextualRevealSimple,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FadeInOutView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_fade_in_out_view.fadeInOutViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FaderWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Curve explorer',
            builder: animated_widgets_fader_widget.faderWidgetCurveExplorer,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowAndFadeWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_grow_and_fade_widget.growAndFadeWidgetDefault,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_grow_widget.growWidgetDefault,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'LengthColoredBorderField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_length_colored_border_field
                .lengthColoredBorderFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PulseWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_pulse_widget.pulseWidgetDefault,
          ),
        ],
      ),
    ],
  ),

  // ─── edittext_popover ────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'edittext_popover',
    children: [
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
    ],
  ),

  // ─── ice_chip ────────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'ice_chip',
    children: [
      WidgetbookComponent(
        name: 'IceChip',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: ice_chip.buildIceChipUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── ice_chips_tray ──────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'ice_chips_tray',
    children: [
      WidgetbookComponent(
        name: 'IceChipsTray',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: ice_chips_tray.buildIceChipsTrayUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IceChipsTrayLayoutList',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                ice_chips_tray_layout_list.buildIceChipsTrayLayoutListUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IceChipsTrayLayoutRow',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                ice_chips_tray_layout_row.buildIceChipsTrayLayoutRowUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IceChipsTrayLayoutWrap',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                ice_chips_tray_layout_wrap.buildIceChipsTrayLayoutWrapUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IcePickerTray',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: ice_chips_tray_ice_picker_tray.buildIcePickerTrayUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── infinite_scroll_picking ─────────────────────────────────────────────
  WidgetbookFolder(
    name: 'infinite_scroll_picking',
    children: [
      WidgetbookComponent(
        name: 'InfiniteScrollPicker<int, String>',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: infinite_scroll_picking.infiniteScrollPickerUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── infinite_scroll_picking_settings ────────────────────────────────────
  WidgetbookFolder(
    name: 'infinite_scroll_picking_settings',
    children: [
      WidgetbookComponent(
        name: 'SettingsScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: infinite_scroll_picking_settings.settingsScreenUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── random_color_generator ──────────────────────────────────────────────
  WidgetbookFolder(
    name: 'random_color_generator',
    children: [
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
    ],
  ),

  // ─── scrolling_datetime_pickers ──────────────────────────────────────────
  WidgetbookFolder(
    name: 'scrolling_datetime_pickers',
    children: [
      WidgetbookComponent(
        name: 'ScrollingDatePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: scrolling_datetime_pickers.scrollingDatePickerDefault,
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
            builder: scrolling_datetime_pickers.scrollingTimePickerDefault,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DateTimePickerField',
        useCases: [
          WidgetbookUseCase(
            name: 'Date & Time',
            builder: scrolling_datetime_pickers.dateTimePickerFieldDateTime,
          ),
          WidgetbookUseCase(
            name: 'Date Only',
            builder: scrolling_datetime_pickers.dateTimePickerFieldDateOnly,
          ),
          WidgetbookUseCase(
            name: 'Time Only',
            builder: scrolling_datetime_pickers.dateTimePickerFieldTimeOnly,
          ),
        ],
      ),
    ],
  ),

  // ─── settings_widget ─────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'settings_widget',
    children: [
      WidgetbookComponent(
        name: 'SettingsWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Custom Title',
            builder: settings_widget.settingsWidgetCustomTitle,
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
            name: 'Large Edge Gap',
            builder: settings_widget.settingsWidgetLargeGap,
          ),
          WidgetbookUseCase(
            name: 'Many Entries (Scrollable)',
            builder: settings_widget.settingsWidgetScrollable,
          ),
          WidgetbookUseCase(
            name: 'No Edge Gap',
            builder: settings_widget.settingsWidgetNoGap,
          ),
          WidgetbookUseCase(
            name: 'Single Entry',
            builder: settings_widget.settingsWidgetSingleEntry,
          ),
          WidgetbookUseCase(
            name: 'Slide from Bottom',
            builder: settings_widget.settingsWidgetDefault,
          ),
          WidgetbookUseCase(
            name: 'Slide from Left',
            builder: settings_widget.settingsWidgetFromLeft,
          ),
          WidgetbookUseCase(
            name: 'Slide from Right',
            builder: settings_widget.settingsWidgetFromRight,
          ),
          WidgetbookUseCase(
            name: 'Slide from Top',
            builder: settings_widget.settingsWidgetFromTop,
          ),
        ],
      ),
    ],
  ),

  // ─── since_when_widgets ──────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'since_when_widgets',
    children: [
      WidgetbookComponent(
        name: 'TagGlossaryEditScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Create',
            builder: since_when_widgets_tag_glossary_edit_create
                .tagGlossaryEditScreenCreateUseCase,
          ),
          WidgetbookUseCase(
            name: 'Update',
            builder: since_when_widgets_tag_glossary_edit_update
                .tagGlossaryEditScreenUpdateUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TagGlossaryReadView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: since_when_widgets_tag_glossary_read
                .tagGlossaryReadViewDefaultUseCase,
          ),
          WidgetbookUseCase(
            name: 'Empty',
            builder: since_when_widgets_tag_glossary_read
                .tagGlossaryReadViewEmptyUseCase,
          ),
          WidgetbookUseCase(
            name: 'Error',
            builder: since_when_widgets_tag_glossary_read
                .tagGlossaryReadViewErrorUseCase,
          ),
          WidgetbookUseCase(
            name: 'Loaded',
            builder: since_when_widgets_tag_glossary_read
                .tagGlossaryReadViewLoadedUseCase,
          ),
          WidgetbookUseCase(
            name: 'Loading',
            builder: since_when_widgets_tag_glossary_read
                .tagGlossaryReadViewLoadingUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── slider_directional ──────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'slider_directional',
    children: [
      WidgetbookComponent(
        name: 'Directional',
        useCases: [
          WidgetbookUseCase(
            name: 'Horizontal — Left (min on left)',
            builder: slider_directional_horizontal.directionalHorizontalLeft,
          ),
          WidgetbookUseCase(
            name: 'Horizontal — Right (min on right)',
            builder: slider_directional_horizontal.directionalHorizontalRight,
          ),
          WidgetbookUseCase(
            name: 'Vertical — Bottom (min at bottom)',
            builder: slider_directional_vertical.directionalVerticalBottom,
          ),
          WidgetbookUseCase(
            name: 'Vertical — Top (min at top)',
            builder: slider_directional_vertical.directionalVerticalTop,
          ),
        ],
      ),
    ],
  ),

  // ─── slider_stepper ──────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'slider_stepper',
    children: [
      WidgetbookComponent(
        name: 'SliderStepper',
        useCases: [
          WidgetbookUseCase(
            name: 'Horizontal — Left (min on left)',
            builder: slider_stepper.sliderStepperHorizontalLeft,
          ),
          WidgetbookUseCase(
            name: 'Horizontal — Right (min on right)',
            builder: slider_stepper.sliderStepperHorizontalRight,
          ),
          WidgetbookUseCase(
            name: 'Vertical — Bottom (min at bottom)',
            builder: slider_stepper.sliderStepperVerticalBottom,
          ),
          WidgetbookUseCase(
            name: 'Vertical — Top (min at top)',
            builder: slider_stepper.sliderStepperVerticalTop,
          ),
        ],
      ),
    ],
  ),

  // ─── sqlite_viewer ───────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'sqlite_viewer',
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

  // ─── theme_widget ────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'theme_widget',
    children: [
      WidgetbookComponent(
        name: 'ThemeWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_widget.themeWidgetUseCase,
          ),
        ],
      ),
    ],
  ),
];
