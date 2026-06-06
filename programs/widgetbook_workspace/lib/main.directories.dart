// dart format width=80
// ignore_for_file: depend_on_referenced_packages

import 'package:widgetbook/widgetbook.dart';

import 'package:widgetbook_workspace/packages/analog_clock_widget/face_and_hand_matrix.usecase.dart'
    as analog_clock_face_and_hand_matrix;
import 'package:widgetbook_workspace/packages/analog_clock_widget/injected_providers.usecase.dart'
    as analog_clock_injected_providers;
import 'package:widgetbook_workspace/packages/analog_clock_widget/playground.usecase.dart'
    as analog_clock_playground;
import 'package:widgetbook_workspace/packages/analog_clock_widget/sizing.usecase.dart'
    as analog_clock_sizing;
import 'package:widgetbook_workspace/packages/analog_clock_widget/themed_presets.usecase.dart'
    as analog_clock_themed_presets;
import 'package:widgetbook_workspace/packages/analog_clock_widget/timezones.usecase.dart'
    as analog_clock_timezones;
import 'package:widgetbook_workspace/packages/analog_clock_widget/toggles.usecase.dart'
    as analog_clock_toggles;
import 'package:widgetbook_workspace/packages/animated_barrier/anchored.usecase.dart'
    as animated_barrier_anchored;
import 'package:widgetbook_workspace/packages/animated_barrier/animation_playground.usecase.dart'
    as animated_barrier_animation_playground;
import 'package:widgetbook_workspace/packages/animated_barrier/barrier_styling.usecase.dart'
    as animated_barrier_barrier_styling;
import 'package:widgetbook_workspace/packages/animated_barrier/centered.usecase.dart'
    as animated_barrier_centered;
import 'package:widgetbook_workspace/packages/animated_barrier/confirm_dialog.usecase.dart'
    as animated_barrier_confirm_dialog;
import 'package:widgetbook_workspace/packages/animated_barrier/fallback_chain.usecase.dart'
    as animated_barrier_fallback_chain;
import 'package:widgetbook_workspace/packages/animated_barrier/imperative_control.usecase.dart'
    as animated_barrier_imperative_control;
import 'package:widgetbook_workspace/packages/animated_barrier/scrollable_list.usecase.dart'
    as animated_barrier_scrollable_list;
import 'package:widgetbook_workspace/packages/animated_barrier/slide_down.usecase.dart'
    as animated_barrier_slide_down;
import 'package:widgetbook_workspace/packages/animated_barrier/slide_up.usecase.dart'
    as animated_barrier_slide_up;
import 'package:widgetbook_workspace/packages/animated_rail_menu/lib/src/widget/animated_rail_menu_widget.usecase.dart'
    as animated_rail_menu;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/animated_checkbox/animated_checkbox.usecase.dart'
    as animated_checkbox;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/animated_overlay/widget/animated_overlay.usecase.dart'
    as animated_overlay;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/contextual_reveal/src/contextual_reveal.usecase.dart'
    as contextual_reveal;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/crossfade_widgets/crossfade_widgets.usecase.dart'
    as crossfade_widgets;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/fade_in_out_view/fade_in_out_view.usecase.dart'
    as fade_in_out_view;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/fader_widget/src/fader_widget.usecase.dart'
    as fader_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/grow_and_fade_widget/grow_and_fade_widget_view.usecase.dart'
    as grow_and_fade_widget_view;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/grow_widget/grow_widget_view.usecase.dart'
    as grow_widget_view;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/length_colored_border_field/length_colored_border_field.usecase.dart'
    as length_colored_border_field;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/pulse_widget/pulse_widget.usecase.dart'
    as pulse_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/lib/src/splash_widget/splash_widget.usecase.dart'
    as splash_widget;
import 'package:widgetbook_workspace/packages/app_preferences/abstract_preferences_interface.usecase.dart'
    as abstract_preferences_interface;
import 'package:widgetbook_workspace/packages/app_preferences/hive_init_mode.usecase.dart'
    as hive_init_mode;
import 'package:widgetbook_workspace/packages/app_preferences/hive_preferences.usecase.dart'
    as hive_preferences;
import 'package:widgetbook_workspace/packages/app_preferences/mock_preferences.usecase.dart'
    as mock_preferences;
import 'package:widgetbook_workspace/packages/custom_widgets/lib/src/anchored/anchored.usecase.dart'
    as anchored;
import 'package:widgetbook_workspace/packages/custom_widgets/lib/src/directional_slider/buttons/directional_slider_and_buttons.usecase.dart'
    as directional_slider_and_buttons;
import 'package:widgetbook_workspace/packages/custom_widgets/lib/src/directional_slider/slider/directional_slider.usecase.dart'
    as directional_slider;
import 'package:widgetbook_workspace/packages/custom_widgets/lib/src/expanding_textfield/expanding_textfield.usecase.dart'
    as expanding_textfield;
import 'package:widgetbook_workspace/packages/custom_widgets/lib/src/uniform_cluster/button_pair.usecase.dart'
    as button_pair;
import 'package:widgetbook_workspace/packages/custom_widgets/lib/src/uniform_cluster/uniform_cluster.usecase.dart'
    as uniform_cluster;
import 'package:widgetbook_workspace/packages/extensions/lib/widget_ext/widget_ext.usecase.dart'
    as widget_ext;
import 'package:widgetbook_workspace/packages/ice_chips/lib/src/ice_chip_tray/ice_chip_tray.usecase.dart'
    as ice_chip_tray;
import 'package:widgetbook_workspace/packages/ice_chips/lib/src/ice_chip_widget/ice_chip.usecase.dart'
    as ice_chip;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picker;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as settings_screen;
import 'package:widgetbook_workspace/packages/random_color_generator/lib/random_color_generator.usecase.dart'
    as random_color_generator;
import 'package:widgetbook_workspace/packages/remind_me/notification_permission_status.usecase.dart'
    as notification_permission_status;
import 'package:widgetbook_workspace/packages/remind_me/remind_me.usecase.dart'
    as remind_me;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field.usecase.dart'
    as datetime_picker_field;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.usecase.dart'
    as datetime_picker_popover;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_date_picker.usecase.dart'
    as scrolling_date_picker;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_time_picker.usecase.dart'
    as scrolling_time_picker;
import 'package:widgetbook_workspace/packages/settings_widget/lib/src/settings_widget.usecase.dart'
    as settings_widget;
import 'package:widgetbook_workspace/packages/since_when_widgets/lib/src/tag_glossary_edit/tag_glossary_edit_screen.usecase.dart'
    as tag_glossary_edit_screen;
import 'package:widgetbook_workspace/packages/since_when_widgets/lib/src/tag_glossary_read/tag_glossary_read_view.usecase.dart'
    as tag_glossary_read_view;
import 'package:widgetbook_workspace/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart'
    as sqlite_viewer_page;
import 'package:widgetbook_workspace/packages/theme_manager/lib/src/theme_service/material_widget.usecase.dart'
    as material_widget;
import 'package:widgetbook_workspace/packages/theme_widget/lib/src/theme_widget.usecase.dart'
    as theme_widget;

final directories = <WidgetbookNode>[
  // ─── analog_clock_widget ─────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'analog_clock_widget',
    children: [
      WidgetbookComponent(
        name: 'AnalogClock',
        useCases: [
          WidgetbookUseCase(
            name: 'Face × Hand matrix',
            builder: analog_clock_face_and_hand_matrix
                .faceAndHandMatrixAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Injected providers (frozen time)',
            builder: analog_clock_injected_providers
                .injectedProvidersAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: analog_clock_playground.playgroundAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Sizing (radius ladder)',
            builder: analog_clock_sizing.sizingAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Themed presets',
            builder:
                analog_clock_themed_presets.themedPresetsAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Toggles (numbers × second hand)',
            builder: analog_clock_toggles.togglesAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'World clocks (timezones)',
            builder: analog_clock_timezones.timezonesAnalogClockUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── animated_barrier ────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'animated_barrier',
    children: [
      WidgetbookComponent(
        name: 'AnimatedBarrier',
        useCases: [
          WidgetbookUseCase(
            name: 'Anchored to button',
            builder: animated_barrier_anchored.anchoredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Animation playground',
            builder: animated_barrier_animation_playground
                .animationPlaygroundAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Barrier styling',
            builder: animated_barrier_barrier_styling
                .barrierStylingAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Centered',
            builder: animated_barrier_centered.centeredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Confirm dialog',
            builder: animated_barrier_confirm_dialog
                .confirmDialogAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Fallback chain',
            builder: animated_barrier_fallback_chain
                .fallbackChainAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Imperative control',
            builder: animated_barrier_imperative_control
                .imperativeControlAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Scrollable list popover',
            builder: animated_barrier_scrollable_list
                .scrollableListAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide down (from top)',
            builder:
                animated_barrier_slide_down.slideDownAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide up (from bottom)',
            builder: animated_barrier_slide_up.slideUpAnimatedBarrierUseCase,
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
            name: 'Default',
            builder: animated_rail_menu.animatedRailMenuUseCase,
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
            builder: animated_checkbox.animatedCheckboxUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimatedOverlay',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_overlay.animatedOverlayUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ContextualReveal',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: contextual_reveal.contextualRevealUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CrossFadeWidgets',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: crossfade_widgets.crossFadeWidgetsUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FadeInOutView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: fade_in_out_view.fadeInOutViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FaderWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: fader_widget.faderWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowAndFadeWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: grow_and_fade_widget_view.growAndFadeWidgetViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: grow_widget_view.growWidgetViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'LengthColoredBorderField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                length_colored_border_field.lengthColoredBorderFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PulseWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: pulse_widget.pulseWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SplashWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: splash_widget.splashWidgetUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── app_preferences ─────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'app_preferences',
    children: [
      WidgetbookComponent(
        name: 'AbstractPreferencesInterfaceShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Contract — absent keys',
            builder: abstract_preferences_interface
                .abstractPreferencesContractAbsent,
          ),
          WidgetbookUseCase(
            name: 'Contract — structural ops',
            builder: abstract_preferences_interface
                .abstractPreferencesContractStructural,
          ),
          WidgetbookUseCase(
            name: 'Contract — type filtering',
            builder: abstract_preferences_interface
                .abstractPreferencesContractTyping,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HiveInitModeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Overview',
            builder: hive_init_mode.hiveInitModeOverview,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HivePreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: hive_preferences.hivePreferencesPlayground,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MockPreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: mock_preferences.mockPreferencesPlayground,
          ),
          WidgetbookUseCase(
            name: 'Test helpers',
            builder: mock_preferences.mockPreferencesTestHelpers,
          ),
        ],
      ),
    ],
  ),

  // ─── custom_widgets ──────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'custom_widgets',
    children: [
      WidgetbookComponent(
        name: 'Anchored',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: anchored.anchoredUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ButtonPair',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: button_pair.buttonPairUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DirectionalSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: directional_slider.directionalSliderUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DirectionalSliderAndButtons',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: directional_slider_and_buttons
                .directionalSliderAndButtonsUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ExpandingTextField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: expanding_textfield.expandingTextFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'UniformCluster',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: uniform_cluster.uniformClusterUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── extensions ──────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'extensions',
    children: [
      WidgetbookComponent(
        name: 'WidgetExtShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Chained transforms',
            builder: widget_ext.widgetExtUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── ice_chips ───────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'ice_chips',
    children: [
      WidgetbookComponent(
        name: 'IceChip',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: ice_chip.iceChipUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IceChipsTray',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: ice_chip_tray.iceChipsTrayUseCase,
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
        name: 'InfiniteScrollPicker<dynamic, dynamic>',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: infinite_scroll_picker.infiniteScrollPickerUseCase,
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
            builder: settings_screen.settingsScreenUseCase,
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
        name: 'RandomColorGeneratorShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Palette',
            builder: random_color_generator.randomColorGeneratorUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── remind_me ───────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'remind_me',
    children: [
      WidgetbookComponent(
        name: 'NotificationPermissionStatusShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'All states overview',
            builder: notification_permission_status
                .notificationPermissionStatusOverview,
          ),
          WidgetbookUseCase(
            name: 'State picker',
            builder: notification_permission_status
                .notificationPermissionStatusPicker,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RemindMeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'API reference',
            builder: remind_me.remindMeApiReference,
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
        name: 'DateTimePickerField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: datetime_picker_field.dateTimePickerFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DateTimePickerPopoverShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: datetime_picker_popover.dateTimePickerPopoverUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ScrollingDatePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: scrolling_date_picker.scrollingDatePickerUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ScrollingTimePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: scrolling_time_picker.scrollingTimePickerUseCase,
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
        name: 'SettingsWidgetShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: settings_widget.settingsWidgetUseCase,
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
            name: 'Default',
            builder: tag_glossary_edit_screen.tagGlossaryEditScreenUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TagGlossaryReadView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: tag_glossary_read_view.tagGlossaryReadViewUseCase,
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
            name: 'Default',
            builder: sqlite_viewer_page.sqliteViewerPageUseCase,
          ),
        ],
      ),
    ],
  ),

  // ─── theme_manager ───────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'theme_manager',
    children: [
      WidgetbookComponent(
        name: 'MaterialWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: material_widget.materialWidgetUseCase,
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
