// dart format width=80
// ignore_for_file: depend_on_referenced_packages

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_workspace/packages/analog_clock_widget/face_and_hand_matrix.usecase.dart'
    as analog_clock_widget_face_and_hand_matrix;
import 'package:widgetbook_workspace/packages/analog_clock_widget/injected_providers.usecase.dart'
    as analog_clock_widget_injected_providers;
import 'package:widgetbook_workspace/packages/analog_clock_widget/playground.usecase.dart'
    as analog_clock_widget_playground;
import 'package:widgetbook_workspace/packages/analog_clock_widget/sizing.usecase.dart'
    as analog_clock_widget_sizing;
import 'package:widgetbook_workspace/packages/analog_clock_widget/themed_presets.usecase.dart'
    as analog_clock_widget_themed_presets;
import 'package:widgetbook_workspace/packages/analog_clock_widget/timezones.usecase.dart'
    as analog_clock_widget_timezones;
import 'package:widgetbook_workspace/packages/analog_clock_widget/toggles.usecase.dart'
    as analog_clock_widget_toggles;
import 'package:widgetbook_workspace/packages/animated_rail_menu/animated_rail_menu_widget.usecase.dart'
    as animated_rail_menu_animated_rail_menu_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/anchored.usecase.dart'
    as animated_widgets_animated_barrier_anchored;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/animation_playground.usecase.dart'
    as animated_widgets_animated_barrier_animation_playground;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/barrier_styling.usecase.dart'
    as animated_widgets_animated_barrier_barrier_styling;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/centered.usecase.dart'
    as animated_widgets_animated_barrier_centered;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/confirm_dialog.usecase.dart'
    as animated_widgets_animated_barrier_confirm_dialog;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/fallback_chain.usecase.dart'
    as animated_widgets_animated_barrier_fallback_chain;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/imperative_control.usecase.dart'
    as animated_widgets_animated_barrier_imperative_control;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/scrollable_list.usecase.dart'
    as animated_widgets_animated_barrier_scrollable_list;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_down.usecase.dart'
    as animated_widgets_animated_barrier_slide_down;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_up.usecase.dart'
    as animated_widgets_animated_barrier_slide_up;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_checkbox/animated_checkbox.usecase.dart'
    as animated_widgets_animated_checkbox_animated_checkbox;
import 'package:widgetbook_workspace/packages/animated_widgets/comination_animation/combination_animation.usecase.dart'
    as animated_widgets_comination_animation_combination_animation;
import 'package:widgetbook_workspace/packages/animated_widgets/contextual_reveal/contextual_reveal.usecase.dart'
    as animated_widgets_contextual_reveal_contextual_reveal;
import 'package:widgetbook_workspace/packages/animated_widgets/crossfade_widgets/crossfade_widgets.usecase.dart'
    as animated_widgets_crossfade_widgets_crossfade_widgets;
import 'package:widgetbook_workspace/packages/animated_widgets/fade_in_out_view/fade_in_out_view.usecase.dart'
    as animated_widgets_fade_in_out_view_fade_in_out_view;
import 'package:widgetbook_workspace/packages/animated_widgets/fader_widget/fader_widget.usecase.dart'
    as animated_widgets_fader_widget_fader_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_and_fade_widget/grow_and_fade_widget_view.usecase.dart'
    as animated_widgets_grow_and_fade_widget_grow_and_fade_widget_view;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_widget/grow_widget_view.usecase.dart'
    as animated_widgets_grow_widget_grow_widget_view;
import 'package:widgetbook_workspace/packages/animated_widgets/length_colored_border_field/length_colored_border_field.usecase.dart'
    as animated_widgets_length_colored_border_field_length_colored_border_field;
import 'package:widgetbook_workspace/packages/animated_widgets/pulse_widget/pulse_widget.usecase.dart'
    as animated_widgets_pulse_widget_pulse_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/splash_widget/splash_flow.usecase.dart'
    as animated_widgets_splash_widget_splash_flow;
import 'package:widgetbook_workspace/packages/animated_widgets/timed_widget/timed_widget.usecase.dart'
    as animated_widgets_timed_widget_timed_widget;
import 'package:widgetbook_workspace/packages/app_preferences/abstract_preferences_interface.usecase.dart'
    as app_preferences_abstract_preferences_interface;
import 'package:widgetbook_workspace/packages/app_preferences/hive_init_mode.usecase.dart'
    as app_preferences_hive_init_mode;
import 'package:widgetbook_workspace/packages/app_preferences/hive_preferences.usecase.dart'
    as app_preferences_hive_preferences;
import 'package:widgetbook_workspace/packages/app_preferences/mock_preferences.usecase.dart'
    as app_preferences_mock_preferences;
import 'package:widgetbook_workspace/packages/custom_widgets/anchored/anchored.usecase.dart'
    as custom_widgets_anchored_anchored;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/buttons/directional_slider_and_buttons.usecase.dart'
    as custom_widgets_directional_slider_buttons_directional_slider_and_buttons;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/slider/directional_slider.usecase.dart'
    as custom_widgets_directional_slider_slider_directional_slider;
import 'package:widgetbook_workspace/packages/custom_widgets/expanding_textfield/expanding_textfield.usecase.dart'
    as custom_widgets_expanding_textfield_expanding_textfield;
import 'package:widgetbook_workspace/packages/custom_widgets/full_screen_color/full_screen_color.usecase.dart'
    as custom_widgets_full_screen_color_full_screen_color;
import 'package:widgetbook_workspace/packages/custom_widgets/orientation_flex/orientation_flex.usecase.dart'
    as custom_widgets_orientation_flex_orientation_flex;
import 'package:widgetbook_workspace/packages/custom_widgets/password_field/password_field.usecase.dart'
    as custom_widgets_password_field_password_field;
import 'package:widgetbook_workspace/packages/custom_widgets/sized_spinner/sized_spinner.usecase.dart'
    as custom_widgets_sized_spinner_sized_spinner;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/button_pair.usecase.dart'
    as custom_widgets_uniform_cluster_button_pair;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/uniform_cluster.usecase.dart'
    as custom_widgets_uniform_cluster_uniform_cluster;
import 'package:widgetbook_workspace/packages/custom_widgets/uninhertied_text/uninherited_text.usecase.dart'
    as custom_widgets_uninhertied_text_uninherited_text;
import 'package:widgetbook_workspace/packages/extensions/datetime_ext/datetime_delta_text.usecase.dart'
    as extensions_datetime_ext_datetime_delta_text;
import 'package:widgetbook_workspace/packages/extensions/widget_ext/widget_ext.usecase.dart'
    as extensions_widget_ext_widget_ext;
import 'package:widgetbook_workspace/packages/ice_chips/ice_chip_tray/ice_chip_tray.usecase.dart'
    as ice_chips_ice_chip_tray_ice_chip_tray;
import 'package:widgetbook_workspace/packages/ice_chips/ice_chip_widget/ice_chip.usecase.dart'
    as ice_chips_ice_chip_widget_ice_chip;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picking_lib_src_infinite_scroll_picker;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as infinite_scroll_picking_settings_settings_screen;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecase.dart'
    as random_color_generator_random_color_generator;
import 'package:widgetbook_workspace/packages/remind_me/notification_permission_status.usecase.dart'
    as remind_me_notification_permission_status;
import 'package:widgetbook_workspace/packages/remind_me/remind_me.usecase.dart'
    as remind_me_remind_me;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_field;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_popover;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_date_picker.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_date_picker;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_time_picker.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_time_picker;
import 'package:widgetbook_workspace/packages/settings_widget/settings_widget.usecase.dart'
    as settings_widget_settings_widget;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_edit_screen.usecase.dart'
    as since_when_widgets_tag_glossary_edit_screen;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_read_view.usecase.dart'
    as since_when_widgets_tag_glossary_read_view;
import 'package:widgetbook_workspace/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart'
    as sqlite_viewer_lib_src_widgets_sqlite_viewer_page_sqlite_viewer_page;
import 'package:widgetbook_workspace/packages/theme_manager/widgets/preference/material_preference.usecase.dart'
    as theme_manager_widgets_preference_material_preference;
import 'package:widgetbook_workspace/packages/theme_manager/widgets/preference/theme_radio_row.usecase.dart'
    as theme_manager_widgets_preference_theme_radio_row;
import 'package:widgetbook_workspace/packages/theme_manager/widgets/preference/theme_selection_body.usecase.dart'
    as theme_manager_widgets_preference_theme_selection_body;
import 'package:widgetbook_workspace/packages/theme_manager/widgets/root/material_root.usecase.dart'
    as theme_manager_widgets_root_material_root;

final directories = <WidgetbookNode>[
  WidgetbookFolder(
    name: 'analog_clock_widget',
    children: [
      WidgetbookComponent(
        name: 'AnalogClock',
        useCases: [
          WidgetbookUseCase(
            name: 'Face × Hand matrix',
            builder: analog_clock_widget_face_and_hand_matrix
                .faceAndHandMatrixAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Injected providers (frozen time)',
            builder: analog_clock_widget_injected_providers
                .injectedProvidersAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: analog_clock_widget_playground
                .playgroundAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Sizing (radius ladder)',
            builder: analog_clock_widget_sizing.sizingAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Themed presets',
            builder: analog_clock_widget_themed_presets
                .themedPresetsAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Toggles (numbers × second hand)',
            builder: analog_clock_widget_toggles.togglesAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'World clocks (timezones)',
            builder: analog_clock_widget_timezones.timezonesAnalogClockUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'animated_rail_menu',
    children: [
      WidgetbookComponent(
        name: 'AnimatedRailMenu',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_rail_menu_animated_rail_menu_widget
                .animatedRailMenuUseCase,
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
            builder: animated_widgets_animated_barrier_anchored
                .anchoredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Animation playground',
            builder: animated_widgets_animated_barrier_animation_playground
                .animationPlaygroundAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Barrier styling',
            builder: animated_widgets_animated_barrier_barrier_styling
                .barrierStylingAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Centered',
            builder: animated_widgets_animated_barrier_centered
                .centeredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Confirm dialog',
            builder: animated_widgets_animated_barrier_confirm_dialog
                .confirmDialogAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Fallback chain',
            builder: animated_widgets_animated_barrier_fallback_chain
                .fallbackChainAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Imperative control',
            builder: animated_widgets_animated_barrier_imperative_control
                .imperativeControlAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Scrollable list popover',
            builder: animated_widgets_animated_barrier_scrollable_list
                .scrollableListAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide down (from top)',
            builder: animated_widgets_animated_barrier_slide_down
                .slideDownAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide up (from bottom)',
            builder: animated_widgets_animated_barrier_slide_up
                .slideUpAnimatedBarrierUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimatedCheckbox',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_animated_checkbox_animated_checkbox
                .animatedCheckboxUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CombinationAnimation',
        useCases: [
          WidgetbookUseCase(
            name: 'Chained x3 (parallel)',
            builder: animated_widgets_comination_animation_combination_animation
                .buildCombinationAnimationChainedUseCase,
          ),
          WidgetbookUseCase(
            name: 'Single',
            builder: animated_widgets_comination_animation_combination_animation
                .buildCombinationAnimationSingleUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CombinationAnimationSequenced',
        useCases: [
          WidgetbookUseCase(
            name: 'Sequenced x3',
            builder: animated_widgets_comination_animation_combination_animation
                .buildCombinationAnimationSequencedUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ContextualReveal',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_contextual_reveal_contextual_reveal
                .contextualRevealUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CrossFadeWidgets',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_crossfade_widgets_crossfade_widgets
                .crossFadeWidgetsUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FadeInOutView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_fade_in_out_view_fade_in_out_view
                .fadeInOutViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FaderWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_fader_widget_fader_widget
                .faderWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowAndFadeWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_grow_and_fade_widget_grow_and_fade_widget_view
                    .growAndFadeWidgetViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_grow_widget_grow_widget_view
                .growWidgetViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'LengthColoredBorderField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_length_colored_border_field_length_colored_border_field
                    .lengthColoredBorderFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PulseWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_pulse_widget_pulse_widget
                .buildPulseWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SplashFlow',
        useCases: [
          WidgetbookUseCase(
            name: 'Splash ends after tasks (no spinner)',
            builder: animated_widgets_splash_widget_splash_flow
                .buildSplashFlowNoSpinnerUseCase,
          ),
          WidgetbookUseCase(
            name: 'Splash ends before tasks (spinner shown)',
            builder: animated_widgets_splash_widget_splash_flow
                .buildSplashFlowSpinnerShownUseCase,
          ),
          WidgetbookUseCase(
            name: 'Task error',
            builder: animated_widgets_splash_widget_splash_flow
                .buildSplashFlowTaskErrorUseCase,
          ),
          WidgetbookUseCase(
            name: 'Tasks time out',
            builder: animated_widgets_splash_widget_splash_flow
                .buildSplashFlowTimeoutUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TimedWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_timed_widget_timed_widget
                .buildTimedWidgetUseCase,
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
            builder: app_preferences_abstract_preferences_interface
                .abstractPreferencesContractAbsent,
          ),
          WidgetbookUseCase(
            name: 'Contract — structural ops',
            builder: app_preferences_abstract_preferences_interface
                .abstractPreferencesContractStructural,
          ),
          WidgetbookUseCase(
            name: 'Contract — type filtering',
            builder: app_preferences_abstract_preferences_interface
                .abstractPreferencesContractTyping,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HiveInitModeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Overview',
            builder: app_preferences_hive_init_mode.hiveInitModeOverview,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HivePreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: app_preferences_hive_preferences.hivePreferencesPlayground,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MockPreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: app_preferences_mock_preferences.mockPreferencesPlayground,
          ),
          WidgetbookUseCase(
            name: 'Test helpers',
            builder: app_preferences_mock_preferences
                .mockPreferencesTestHelpers,
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
            builder: custom_widgets_anchored_anchored.anchoredUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ButtonPair',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_uniform_cluster_button_pair
                .buttonPairUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DirectionalSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_directional_slider_slider_directional_slider
                .directionalSliderUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DirectionalSliderAndButtons',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                custom_widgets_directional_slider_buttons_directional_slider_and_buttons
                    .directionalSliderAndButtonsUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ExpandingTextField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_expanding_textfield_expanding_textfield
                .expandingTextFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FullScreenColor',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_full_screen_color_full_screen_color
                .buildFullScreenColorUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'OrientationFlex',
        useCases: [
          WidgetbookUseCase(
            name: 'Login / Register',
            builder: custom_widgets_orientation_flex_orientation_flex
                .buildOrientationFlexUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PasswordField',
        useCases: [
          WidgetbookUseCase(
            name: 'Long Value (wraps when revealed)',
            builder: custom_widgets_password_field_password_field
                .passwordFieldLongValueUseCase,
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: custom_widgets_password_field_password_field
                .passwordFieldPlaygroundUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SizedSpinner',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_sized_spinner_sized_spinner
                .buildSizedSpinnerUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'UniformCluster',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_uniform_cluster_uniform_cluster
                .uniformClusterUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'UninheritedText',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_uninhertied_text_uninherited_text
                .buildUninheritedTextUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'extensions',
    children: [
      WidgetbookComponent(
        name: 'DateTimeDeltaText',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: extensions_datetime_ext_datetime_delta_text
                .buildDateTimeDeltaTextUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Widget',
        useCases: [
          WidgetbookUseCase(
            name: 'Widget Extensions',
            builder: extensions_widget_ext_widget_ext.buildWidgetExtUseCase,
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
            builder: ice_chips_ice_chip_widget_ice_chip.iceChipUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IceChipsTray',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: ice_chips_ice_chip_tray_ice_chip_tray.iceChipsTrayUseCase,
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
            builder: infinite_scroll_picking_lib_src_infinite_scroll_picker
                .infiniteScrollPickerUseCase,
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
    name: 'random_color_generator',
    children: [
      WidgetbookComponent(
        name: 'RandomColorGeneratorShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Palette',
            builder: random_color_generator_random_color_generator
                .randomColorGeneratorUseCase,
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
            builder: remind_me_notification_permission_status
                .notificationPermissionStatusOverview,
          ),
          WidgetbookUseCase(
            name: 'State picker',
            builder: remind_me_notification_permission_status
                .notificationPermissionStatusPicker,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RemindMeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'API reference',
            builder: remind_me_remind_me.remindMeApiReference,
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
            builder:
                scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_field
                    .dateTimePickerFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DateTimePickerPopoverShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_popover
                    .dateTimePickerPopoverUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ScrollingDatePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_date_picker
                    .scrollingDatePickerUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ScrollingTimePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_time_picker
                    .scrollingTimePickerUseCase,
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
            builder: settings_widget_settings_widget.settingsWidgetUseCase,
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
            builder: since_when_widgets_tag_glossary_edit_screen
                .tagGlossaryEditScreenUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TagGlossaryReadView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: since_when_widgets_tag_glossary_read_view
                .tagGlossaryReadViewUseCase,
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
            builder:
                sqlite_viewer_lib_src_widgets_sqlite_viewer_page_sqlite_viewer_page
                    .sqliteViewerPageUseCase,
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
            name: 'Default',
            builder: theme_manager_widgets_preference_material_preference
                .buildMaterialPreferenceUseCase,
          ),
          WidgetbookUseCase(
            name: 'Localized (Spanish)',
            builder: theme_manager_widgets_preference_material_preference
                .buildMaterialPreferenceLocalizedUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MaterialRoot',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_manager_widgets_root_material_root
                .buildMaterialRootUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeRadioRow',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_manager_widgets_preference_theme_radio_row
                .buildThemeRadioRowUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeSelectionBody',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_manager_widgets_preference_theme_selection_body
                .buildThemeSelectionBodyUseCase,
          ),
        ],
      ),
    ],
  ),
];
