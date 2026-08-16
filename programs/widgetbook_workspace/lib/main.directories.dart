// programs/widgetbook_workspace/lib/main.directories.dart

// dart format width=80
// ignore_for_file: depend_on_referenced_packages

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_workspace/packages/analog_clock_widget/face_and_hand_matrix.usecase.dart'
    as face_and_hand_matrix;
import 'package:widgetbook_workspace/packages/analog_clock_widget/injected_providers.usecase.dart'
    as injected_providers;
import 'package:widgetbook_workspace/packages/analog_clock_widget/playground.usecase.dart'
    as playground;
import 'package:widgetbook_workspace/packages/analog_clock_widget/sizing.usecase.dart'
    as sizing;
import 'package:widgetbook_workspace/packages/analog_clock_widget/themed_presets.usecase.dart'
    as themed_presets;
import 'package:widgetbook_workspace/packages/analog_clock_widget/timezones.usecase.dart'
    as timezones;
import 'package:widgetbook_workspace/packages/analog_clock_widget/toggles.usecase.dart'
    as toggles;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/anchored.usecase.dart'
    as animated_widgets_anchored;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/animation_playground.usecase.dart'
    as animation_playground;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/barrier_styling.usecase.dart'
    as barrier_styling;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/centered.usecase.dart'
    as centered;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/confirm_dialog.usecase.dart'
    as confirm_dialog;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/fallback_chain.usecase.dart'
    as fallback_chain;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/imperative_control.usecase.dart'
    as imperative_control;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/scrollable_list.usecase.dart'
    as scrollable_list;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_down.usecase.dart'
    as slide_down;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_up.usecase.dart'
    as slide_up;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_checkbox/animated_checkbox.usecase.dart'
    as animated_checkbox;
import 'package:widgetbook_workspace/packages/animated_widgets/contextual_reveal/contextual_reveal.usecase.dart'
    as contextual_reveal;
import 'package:widgetbook_workspace/packages/animated_widgets/crossfade_widgets/crossfade_widgets.usecase.dart'
    as crossfade_widgets;
import 'package:widgetbook_workspace/packages/animated_widgets/fade_in_out_view/fade_in_out_view.usecase.dart'
    as fade_in_out_view;
import 'package:widgetbook_workspace/packages/animated_widgets/fader_widget/fader_widget.usecase.dart'
    as fader_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_and_fade_widget/grow_and_fade_widget_view.usecase.dart'
    as grow_and_fade_widget_view;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_widget/grow_widget_view.usecase.dart'
    as grow_widget_view;
import 'package:widgetbook_workspace/packages/animated_widgets/length_colored_border_field/length_colored_border_field.usecase.dart'
    as length_colored_border_field;
import 'package:widgetbook_workspace/packages/animated_widgets/pill_widget/pill_widget.usecase.dart'
    as pill_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/pulse_widget/pulse_widget.usecase.dart'
    as pulse_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/splash_widget/splash_flow.usecase.dart'
    as splash_flow;
import 'package:widgetbook_workspace/packages/animated_widgets/timed_widget/timed_widget.usecase.dart'
    as timed_widget;
import 'package:widgetbook_workspace/packages/app_preferences/abstract_preferences_interface.usecase.dart'
    as abstract_preferences_interface;
import 'package:widgetbook_workspace/packages/app_preferences/hive_init_mode.usecase.dart'
    as hive_init_mode;
import 'package:widgetbook_workspace/packages/app_preferences/hive_preferences.usecase.dart'
    as hive_preferences;
import 'package:widgetbook_workspace/packages/app_preferences/mock_preferences.usecase.dart'
    as mock_preferences;
import 'package:widgetbook_workspace/packages/color_grid/color_grid.usecase.dart'
    as color_grid;
import 'package:widgetbook_workspace/packages/custom_widgets/anchored/anchored.usecase.dart'
    as custom_widgets_anchored;
import 'package:widgetbook_workspace/packages/custom_widgets/crash_screen/crash_screen.usecase.dart'
    as crash_screen;
import 'package:widgetbook_workspace/packages/custom_widgets/default_welcome_screen/default_welcome_screen.usecase.dart'
    as default_welcome_screen;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/buttons/directional_slider_and_buttons.usecase.dart'
    as directional_slider_and_buttons;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/slider/directional_slider.usecase.dart'
    as directional_slider;
import 'package:widgetbook_workspace/packages/custom_widgets/expanding_textfield/expanding_textfield.usecase.dart'
    as expanding_textfield;
import 'package:widgetbook_workspace/packages/custom_widgets/orientation_flex/orientation_flex.usecase.dart'
    as orientation_flex;
import 'package:widgetbook_workspace/packages/custom_widgets/sized_spinner/sized_spinner.usecase.dart'
    as sized_spinner;
import 'package:widgetbook_workspace/packages/custom_widgets/slide_index_stack/slide_index_stack.usecase.dart'
    as slide_index_stack;
import 'package:widgetbook_workspace/packages/custom_widgets/solid_screen_color/solid_screen_color.usecase.dart'
    as solid_screen_color;
import 'package:widgetbook_workspace/packages/custom_widgets/textfield/input_field.usecase.dart'
    as input_field;
import 'package:widgetbook_workspace/packages/custom_widgets/textfield/password_field.usecase.dart'
    as password_field;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/button_pair.usecase.dart'
    as button_pair;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/uniform_cluster.usecase.dart'
    as uniform_cluster;
import 'package:widgetbook_workspace/packages/custom_widgets/uninhertied_text/uninherited_text.usecase.dart'
    as uninherited_text;
import 'package:widgetbook_workspace/packages/data_grid/data_grid.usecase.dart'
    as data_grid;
import 'package:widgetbook_workspace/packages/extensions/widget_ext/widget_ext.usecase.dart'
    as widget_ext;
import 'package:widgetbook_workspace/packages/ice_chips/ice_chip_tray/ice_chip_tray.usecase.dart'
    as ice_chip_tray;
import 'package:widgetbook_workspace/packages/ice_chips/ice_chip_widget/ice_chip.usecase.dart'
    as ice_chip;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picker;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as infinite_scroll_picking_settings_settings_screen;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_button.usecase.dart'
    as rail_button;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_button_presets.usecase.dart'
    as rail_button_presets;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_overflow_button.usecase.dart'
    as rail_overflow_button;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_popover_tile.usecase.dart'
    as rail_popover_tile;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_shell.usecase.dart'
    as rail_shell;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_widget.usecase.dart'
    as rail_widget;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecase.dart'
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
import 'package:widgetbook_workspace/packages/settings_widget/settings_widget.usecase.dart'
    as settings_widget;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_edit_screen.usecase.dart'
    as tag_glossary_edit_screen;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_read_view.usecase.dart'
    as tag_glossary_read_view;
import 'package:widgetbook_workspace/packages/splash_framework/splash_screen.usecase.dart'
    as splash_screen;
import 'package:widgetbook_workspace/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart'
    as sqlite_viewer_page;
import 'package:widgetbook_workspace/packages/stacking_widgets/stacking_widgets.usecase.dart'
    as stacking_widgets;
import 'package:widgetbook_workspace/packages/theme_framework/settings_screen.usecase.dart'
    as theme_framework_settings_screen;
import 'package:widgetbook_workspace/packages/theme_framework/theme_mode_card.usecase.dart'
    as theme_mode_card;
import 'package:widgetbook_workspace/packages/theme_framework/theme_mode_entry.usecase.dart'
    as theme_mode_entry;
import 'package:widgetbook_workspace/packages/theme_framework/theme_setting_screen.usecase.dart'
    as theme_setting_screen;
import 'package:widgetbook_workspace/packages/theme_manager/material_preference.usecase.dart'
    as material_preference;
import 'package:widgetbook_workspace/packages/theme_manager/theme_radio_row.usecase.dart'
    as theme_radio_row;
import 'package:widgetbook_workspace/packages/theme_manager/theme_selection_body.usecase.dart'
    as theme_selection_body;
import 'package:widgetbook_workspace/packages/three_d_sphere/three_d_sphere.usecase.dart'
    as three_d_sphere;
import 'package:widgetbook_workspace/packages/widget_animation_framework/animation_combiner_on_widget.usecase.dart'
    as animation_combiner_on_widget;
import 'package:widgetbook_workspace/packages/widget_animation_framework/animation_controller_widget.usecase.dart.dart'
    as animation_controller_widget;

final directories = <WidgetbookNode>[
  WidgetbookFolder(
    name: 'analog_clock_widget',
    children: [
      WidgetbookComponent(
        name: 'AnalogClock',
        useCases: [
          WidgetbookUseCase(
            name: 'Face × Hand matrix',
            builder: face_and_hand_matrix.faceAndHandMatrixAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Injected providers (frozen time)',
            builder: injected_providers.injectedProvidersAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: playground.playgroundAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Sizing (radius ladder)',
            builder: sizing.sizingAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Themed presets',
            builder: themed_presets.themedPresetsAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Toggles (numbers × second hand)',
            builder: toggles.togglesAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'World clocks (timezones)',
            builder: timezones.timezonesAnalogClockUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'animated_widgets',
    children: [
      WidgetbookComponent(
        name: 'AnimatedBarrier',
        useCases: [
          WidgetbookUseCase(
            name: 'Anchored to button',
            builder: animated_widgets_anchored.anchoredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Barrier styling',
            builder: barrier_styling.barrierStylingAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'BarrierAnimation playground',
            builder:
                animation_playground.animationPlaygroundAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Centered',
            builder: centered.centeredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Confirm dialog',
            builder: confirm_dialog.confirmDialogAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Fallback chain',
            builder: fallback_chain.fallbackChainAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Imperative control',
            builder: imperative_control.imperativeControlAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Scrollable list popover',
            builder: scrollable_list.scrollableListAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide down (from top)',
            builder: slide_down.slideDownAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide up (from bottom)',
            builder: slide_up.slideUpAnimatedBarrierUseCase,
          ),
        ],
      ),
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
        name: 'PillWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: pill_widget.buildPillWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PulseWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: pulse_widget.buildPulseWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SplashScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Splash ends after tasks (no spinner)',
            builder: splash_flow.buildSplashFlowNoSpinnerUseCase,
          ),
          WidgetbookUseCase(
            name: 'Splash ends before tasks (spinner shown)',
            builder: splash_flow.buildSplashFlowSpinnerShownUseCase,
          ),
          WidgetbookUseCase(
            name: 'Task error',
            builder: splash_flow.buildSplashFlowTaskErrorUseCase,
          ),
          WidgetbookUseCase(
            name: 'Tasks time out',
            builder: splash_flow.buildSplashFlowTimeoutUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TimedWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: timed_widget.buildTimedWidgetUseCase,
          ),
        ],
      ),
    ],
  ),
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
  WidgetbookFolder(
    name: 'color_grid',
    children: [
      WidgetbookComponent(
        name: 'ColorGrid',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: color_grid.buildColorGridUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'custom_widgets',
    children: [
      WidgetbookComponent(
        name: 'Anchored',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_anchored.anchoredUseCase,
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
        name: 'CrashScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: crash_screen.buildCrashScreenUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DefaultWelcomeScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: default_welcome_screen.buildDefaultWelcomeScreenUseCase,
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
        name: 'InputField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: input_field.buildInputFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'OrientationFlex',
        useCases: [
          WidgetbookUseCase(
            name: 'Login / Register',
            builder: orientation_flex.buildOrientationFlexUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PasswordField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: password_field.buildPasswordFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SizedSpinner',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sized_spinner.buildSizedSpinnerUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SlideIndexedStack',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: slide_index_stack.buildSlideIndexedStackUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SolidScreenColor',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: solid_screen_color.buildSolidScreenColorUseCase,
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
      WidgetbookComponent(
        name: 'UninheritedText',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: uninherited_text.buildUninheritedTextUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'data_grid',
    children: [
      WidgetbookComponent(
        name: 'DataGrid',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: data_grid.buildDataGridUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'extensions',
    children: [
      WidgetbookComponent(
        name: 'Widget',
        useCases: [
          WidgetbookUseCase(
            name: 'Widget Extensions',
            builder: widget_ext.buildWidgetExtUseCase,
          ),
        ],
      ),
    ],
  ),
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
  WidgetbookFolder(
    name: 'infinite_scroll_picking_settings',
    children: [
      WidgetbookComponent(
        name: 'SettingsScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: infinite_scroll_picking_settings_settings_screen
                .settingsScreenUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'rail_navigation',
    children: [
      WidgetbookComponent(
        name: 'MainRailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_button_presets.buildMainRailButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MoreRailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_button_presets.buildMoreRailButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_button.buildRailButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailOverflowButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_overflow_button.buildRailOverflowButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailPopoverTile',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_popover_tile.buildRailPopoverTileUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailShell',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_shell.buildRailShellUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_widget.buildRailWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SettingsRailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_button_presets.buildSettingsRailButtonUseCase,
          ),
        ],
      ),
    ],
  ),
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
  WidgetbookFolder(
    name: 'splash_framework',
    children: [
      WidgetbookComponent(
        name: 'SplashScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: splash_screen.buildSplashScreenUseCase,
          ),
        ],
      ),
    ],
  ),
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
  WidgetbookFolder(
    name: 'stacking_widgets',
    children: [
      WidgetbookComponent(
        name: 'StackingWidgets',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: stacking_widgets.buildStackingWidgetsUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'theme_framework',
    children: [
      WidgetbookComponent(
        name: 'SettingsScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Custom entries',
            builder: theme_framework_settings_screen.buildSettingsScreenUseCase,
          ),
          WidgetbookUseCase(
            name: 'With theme',
            builder: theme_framework_settings_screen
                .buildSettingsScreenWithThemeUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeModeCard',
        useCases: [
          WidgetbookUseCase(
            name: 'Controlled',
            builder: theme_mode_card.buildThemeModeCardUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeModeEntry',
        useCases: [
          WidgetbookUseCase(
            name: 'Live',
            builder: theme_mode_entry.buildThemeModeEntryUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeSettingScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_setting_screen.buildThemeSettingScreenUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'theme_manager',
    children: [
      WidgetbookComponent(
        name: 'MaterialPreference',
        useCases: [
          WidgetbookUseCase(
            name: 'Live',
            builder: material_preference.buildMaterialPreferenceUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeRadioRow',
        useCases: [
          WidgetbookUseCase(
            name: 'Controlled',
            builder: theme_radio_row.buildThemeRadioRowUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeSelectionBody',
        useCases: [
          WidgetbookUseCase(
            name: 'Controlled',
            builder: theme_selection_body.buildThemeSelectionBodyUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'three_d_sphere',
    children: [
      WidgetbookComponent(
        name: 'ThreeDSphere',
        useCases: [
          WidgetbookUseCase(
            name: 'Parametric',
            builder: three_d_sphere.buildThreeDSphereUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'widget_animation_framework',
    children: [
      WidgetbookComponent(
        name: 'AnimationCombinerOnWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Scrubbed',
            builder: animation_combiner_on_widget
                .buildAnimationCombinerOnWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimationControllerWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Play on mount',
            builder: animation_controller_widget
                .buildAnimationControllerWidgetUseCase,
          ),
        ],
      ),
    ],
  ),
];
