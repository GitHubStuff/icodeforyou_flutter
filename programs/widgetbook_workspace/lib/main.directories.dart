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
import 'package:widgetbook_workspace/packages/animated_widgets/pill_widget/pill_widget.usecase.dart'
    as animated_widgets_pill_widget_pill_widget;
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
import 'package:widgetbook_workspace/packages/color_grid/color_grid.usecase.dart'
    as color_grid_color_grid;
import 'package:widgetbook_workspace/packages/custom_widgets/anchored/anchored.usecase.dart'
    as custom_widgets_anchored_anchored;
import 'package:widgetbook_workspace/packages/custom_widgets/crash_screen/crash_screen.usecase.dart'
    as custom_widgets_crash_screen_crash_screen;
import 'package:widgetbook_workspace/packages/custom_widgets/default_welcome_screen/default_welcome_screen.usecase.dart'
    as custom_widgets_default_welcome_screen_default_welcome_screen;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/buttons/directional_slider_and_buttons.usecase.dart'
    as custom_widgets_directional_slider_buttons_directional_slider_and_buttons;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/slider/directional_slider.usecase.dart'
    as custom_widgets_directional_slider_slider_directional_slider;
import 'package:widgetbook_workspace/packages/custom_widgets/expanding_textfield/expanding_textfield.usecase.dart'
    as custom_widgets_expanding_textfield_expanding_textfield;
import 'package:widgetbook_workspace/packages/custom_widgets/ice_chip/ice_chip/ice_chip.usecase.dart'
    as custom_widgets_ice_chip_ice_chip_ice_chip;
import 'package:widgetbook_workspace/packages/custom_widgets/orientation_flex/orientation_flex.usecase.dart'
    as custom_widgets_orientation_flex_orientation_flex;
import 'package:widgetbook_workspace/packages/custom_widgets/sized_spinner/sized_spinner.usecase.dart'
    as custom_widgets_sized_spinner_sized_spinner;
import 'package:widgetbook_workspace/packages/custom_widgets/slide_index_stack/slide_index_stack.usecase.dart'
    as custom_widgets_slide_index_stack_slide_index_stack;
import 'package:widgetbook_workspace/packages/custom_widgets/solid_screen_color/solid_screen_color.usecase.dart'
    as custom_widgets_solid_screen_color_solid_screen_color;
import 'package:widgetbook_workspace/packages/custom_widgets/textfield/input_field.usecase.dart'
    as custom_widgets_textfield_input_field;
import 'package:widgetbook_workspace/packages/custom_widgets/textfield/password_field.usecase.dart'
    as custom_widgets_textfield_password_field;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/button_pair.usecase.dart'
    as custom_widgets_uniform_cluster_button_pair;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/uniform_cluster.usecase.dart'
    as custom_widgets_uniform_cluster_uniform_cluster;
import 'package:widgetbook_workspace/packages/custom_widgets/uninhertied_text/uninherited_text.usecase.dart'
    as custom_widgets_uninhertied_text_uninherited_text;
import 'package:widgetbook_workspace/packages/data_grid/data_grid.usecase.dart'
    as data_grid_data_grid;
import 'package:widgetbook_workspace/packages/extensions/color_ext/color_pair.usecase.dart'
    as extensions_color_ext_color_pair;
import 'package:widgetbook_workspace/packages/extensions/widget_ext/widget_ext.usecase.dart'
    as extensions_widget_ext_widget_ext;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picking_lib_src_infinite_scroll_picker;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as infinite_scroll_picking_settings_settings_screen;
import 'package:widgetbook_workspace/packages/prism_bubble_widget/animated_prism_bubble.usecase.dart'
    as prism_bubble_widget_animated_prism_bubble;
import 'package:widgetbook_workspace/packages/prism_bubble_widget/dynamic_prism_bubble.usecase.dart'
    as prism_bubble_widget_dynamic_prism_bubble;
import 'package:widgetbook_workspace/packages/prism_bubble_widget/prism_bubble_widget.usecase.dart'
    as prism_bubble_widget_prism_bubble_widget;
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
import 'package:widgetbook_workspace/packages/sincewhen_screens/sincewhen_mini/since_when_mini.usecase.dart'
    as sincewhen_screens_sincewhen_mini_since_when_mini;
import 'package:widgetbook_workspace/packages/sincewhen_screens/widgets/event_timestamp_row.usecase.dart'
    as sincewhen_screens_widgets_event_timestamp_row;
import 'package:widgetbook_workspace/packages/sincewhen_screens/widgets/since_when_mini_action_bar.usecase.dart'
    as sincewhen_screens_widgets_since_when_mini_action_bar;
import 'package:widgetbook_workspace/packages/sincewhen_screens/widgets/since_when_mini_text_column.usecase.dart'
    as sincewhen_screens_widgets_since_when_mini_text_column;
import 'package:widgetbook_workspace/packages/sincewhen_screens/widgets/sincewhen_mini_timestamp_column.usecase.dart'
    as sincewhen_screens_widgets_sincewhen_mini_timestamp_column;
import 'package:widgetbook_workspace/packages/sincewhen_screens/widgets/timestamp_row.usecase.dart'
    as sincewhen_screens_widgets_timestamp_row;
import 'package:widgetbook_workspace/packages/sincewhen_widgets/glossary_card.usecase.dart'
    as sincewhen_widgets_glossary_card;
import 'package:widgetbook_workspace/packages/sincewhen_widgets/glossary_item_create_dialog.usecase.dart'
    as sincewhen_widgets_glossary_item_create_dialog;
import 'package:widgetbook_workspace/packages/splash_framework/splash_screen.usecase.dart'
    as splash_framework_splash_screen;
import 'package:widgetbook_workspace/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart'
    as sqlite_viewer_lib_src_widgets_sqlite_viewer_page_sqlite_viewer_page;
import 'package:widgetbook_workspace/packages/stacking_widgets/stacking_widgets.usecase.dart'
    as stacking_widgets_stacking_widgets;
import 'package:widgetbook_workspace/packages/theme_framework/settings_screen.usecase.dart'
    as theme_framework_settings_screen;
import 'package:widgetbook_workspace/packages/theme_framework/theme_mode_card.usecase.dart'
    as theme_framework_theme_mode_card;
import 'package:widgetbook_workspace/packages/theme_framework/theme_mode_entry.usecase.dart'
    as theme_framework_theme_mode_entry;
import 'package:widgetbook_workspace/packages/theme_framework/theme_setting_screen.usecase.dart'
    as theme_framework_theme_setting_screen;
import 'package:widgetbook_workspace/packages/three_d_sphere/three_d_sphere.usecase.dart'
    as three_d_sphere_three_d_sphere;
import 'package:widgetbook_workspace/packages/widget_animation_framework/animation_combiner_on_widget.usecase.dart'
    as widget_animation_framework_animation_combiner_on_widget;
import 'package:widgetbook_workspace/packages/widget_animation_framework/animation_controller_widget.usecase.dart'
    as widget_animation_framework_animation_controller_widget;

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
            builder:
                analog_clock_widget_playground.playgroundAnalogClockUseCase,
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
            name: 'Barrier styling',
            builder: animated_widgets_animated_barrier_barrier_styling
                .barrierStylingAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'BarrierAnimation playground',
            builder: animated_widgets_animated_barrier_animation_playground
                .animationPlaygroundAnimatedBarrierUseCase,
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
            builder:
                animated_widgets_fader_widget_fader_widget.faderWidgetUseCase,
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
        name: 'PillWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_pill_widget_pill_widget.buildPillWidgetUseCase,
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
        name: 'SplashScreen',
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
            builder:
                app_preferences_mock_preferences.mockPreferencesTestHelpers,
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
            builder: color_grid_color_grid.buildColorGridUseCase,
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
            builder:
                custom_widgets_uniform_cluster_button_pair.buttonPairUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CrashScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_crash_screen_crash_screen
                .buildCrashScreenUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DefaultWelcomeScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                custom_widgets_default_welcome_screen_default_welcome_screen
                    .buildDefaultWelcomeScreenUseCase,
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
        name: 'IceChip',
        useCases: [
          WidgetbookUseCase(
            name: 'Default (widget child)',
            builder: custom_widgets_ice_chip_ice_chip_ice_chip
                .buildIceChipDefaultUseCase,
          ),
          WidgetbookUseCase(
            name: 'Text',
            builder: custom_widgets_ice_chip_ice_chip_ice_chip
                .buildIceChipTextUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'InputField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                custom_widgets_textfield_input_field.buildInputFieldUseCase,
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
            name: 'Default',
            builder: custom_widgets_textfield_password_field
                .buildPasswordFieldUseCase,
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
        name: 'SlideIndexedStack',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_slide_index_stack_slide_index_stack
                .buildSlideIndexedStackUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SolidScreenColor',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_solid_screen_color_solid_screen_color
                .buildSolidScreenColorUseCase,
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
    name: 'data_grid',
    children: [
      WidgetbookComponent(
        name: 'DataGrid',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: data_grid_data_grid.buildDataGridUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'extensions',
    children: [
      WidgetbookComponent(
        name: 'ColorPair',
        useCases: [
          WidgetbookUseCase(
            name: 'Interactive',
            builder: extensions_color_ext_color_pair.colorPairInteractive,
          ),
          WidgetbookUseCase(
            name: 'Preset Gallery',
            builder: extensions_color_ext_color_pair.colorPairGallery,
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
    name: 'prism_bubble_widget',
    children: [
      WidgetbookComponent(
        name: 'AnimatedPrismBubble',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: prism_bubble_widget_animated_prism_bubble
                .buildAnimatedPrismBubbleUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DynamicPrismBubble',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: prism_bubble_widget_dynamic_prism_bubble
                .buildDynamicPrismBubbleUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PrismBubbleWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Custom (Knobs)',
            builder: prism_bubble_widget_prism_bubble_widget
                .buildCustomPrismBubbleUseCase,
          ),
          WidgetbookUseCase(
            name: 'Factory Dark',
            builder: prism_bubble_widget_prism_bubble_widget
                .buildDarkFactoryPrismBubbleUseCase,
          ),
          WidgetbookUseCase(
            name: 'Factory Light',
            builder: prism_bubble_widget_prism_bubble_widget
                .buildLightFactoryPrismBubbleUseCase,
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
    name: 'sincewhen_screens',
    children: [
      WidgetbookComponent(
        name: 'EventTimestampRow',
        useCases: [
          WidgetbookUseCase(
            name: 'Empty',
            builder: sincewhen_screens_widgets_event_timestamp_row
                .buildEventTimestampRowEmptyUseCase,
          ),
          WidgetbookUseCase(
            name: 'With value',
            builder: sincewhen_screens_widgets_event_timestamp_row
                .buildEventTimestampRowWithValueUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SinceWhenMini',
        useCases: [
          WidgetbookUseCase(
            name: 'Create flow',
            builder: sincewhen_screens_sincewhen_mini_since_when_mini
                .buildSinceWhenMiniCreateFlowUseCase,
          ),
          WidgetbookUseCase(
            name: 'Edit flow',
            builder: sincewhen_screens_sincewhen_mini_since_when_mini
                .buildSinceWhenMiniEditFlowUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SinceWhenMiniActionBar',
        useCases: [
          WidgetbookUseCase(
            name: 'Interactive',
            builder: sincewhen_screens_widgets_since_when_mini_action_bar
                .buildSinceWhenMiniActionBarUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SinceWhenMiniTextColumn',
        useCases: [
          WidgetbookUseCase(
            name: 'Empty',
            builder: sincewhen_screens_widgets_since_when_mini_text_column
                .buildSinceWhenMiniTextColumnEmptyUseCase,
          ),
          WidgetbookUseCase(
            name: 'Pre-filled',
            builder: sincewhen_screens_widgets_since_when_mini_text_column
                .buildSinceWhenMiniTextColumnPreFilledUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SinceWhenMiniTimestampColumn',
        useCases: [
          WidgetbookUseCase(
            name: 'Create mode',
            builder: sincewhen_screens_widgets_sincewhen_mini_timestamp_column
                .buildSinceWhenMiniTimestampColumnCreateUseCase,
          ),
          WidgetbookUseCase(
            name: 'Edit mode',
            builder: sincewhen_screens_widgets_sincewhen_mini_timestamp_column
                .buildSinceWhenMiniTimestampColumnEditUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TimestampRow',
        useCases: [
          WidgetbookUseCase(
            name: 'Interactive',
            builder: sincewhen_screens_widgets_timestamp_row
                .buildTimestampRowUseCase,
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'sincewhen_widgets',
    children: [
      WidgetbookComponent(
        name: 'GlossaryCard',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sincewhen_widgets_glossary_card.defaultGlossaryCard,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GlossaryItemCreateDialog',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sincewhen_widgets_glossary_item_create_dialog
                .glossaryItemCreateDialogDefaultUseCase,
          ),
          WidgetbookUseCase(
            name: 'Inline Presentation',
            builder: sincewhen_widgets_glossary_item_create_dialog
                .glossaryItemCreateDialogInlineUseCase,
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
            builder: splash_framework_splash_screen.buildSplashScreenUseCase,
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
    name: 'stacking_widgets',
    children: [
      WidgetbookComponent(
        name: 'StackingWidgets',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                stacking_widgets_stacking_widgets.buildStackingWidgetsUseCase,
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
            builder: theme_framework_theme_mode_card.buildThemeModeCardUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeModeEntry',
        useCases: [
          WidgetbookUseCase(
            name: 'Live',
            builder:
                theme_framework_theme_mode_entry.buildThemeModeEntryUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeSettingScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_framework_theme_setting_screen
                .buildThemeSettingScreenUseCase,
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
            builder: three_d_sphere_three_d_sphere.buildThreeDSphereUseCase,
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
            builder: widget_animation_framework_animation_combiner_on_widget
                .buildAnimationCombinerOnWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimationControllerWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Play on mount',
            builder: widget_animation_framework_animation_controller_widget
                .buildAnimationControllerWidgetUseCase,
          ),
        ],
      ),
    ],
  ),
];
