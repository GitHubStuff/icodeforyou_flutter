// dart format width=80
// ignore_for_file: depend_on_referenced_packages

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_workspace/packages/analog_clock_widget/face_and_hand_matrix.usecase.dart'
    as analog_clock_widget_face_and_hand_matrix_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/injected_providers.usecase.dart'
    as analog_clock_widget_injected_providers_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/playground.usecase.dart'
    as analog_clock_widget_playground_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/sizing.usecase.dart'
    as analog_clock_widget_sizing_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/themed_presets.usecase.dart'
    as analog_clock_widget_themed_presets_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/timezones.usecase.dart'
    as analog_clock_widget_timezones_usecase;
import 'package:widgetbook_workspace/packages/analog_clock_widget/toggles.usecase.dart'
    as analog_clock_widget_toggles_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/anchored.usecase.dart'
    as animated_widgets_animated_barrier_anchored_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/animation_playground.usecase.dart'
    as animated_widgets_animated_barrier_animation_playground_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/barrier_styling.usecase.dart'
    as animated_widgets_animated_barrier_barrier_styling_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/centered.usecase.dart'
    as animated_widgets_animated_barrier_centered_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/confirm_dialog.usecase.dart'
    as animated_widgets_animated_barrier_confirm_dialog_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/fallback_chain.usecase.dart'
    as animated_widgets_animated_barrier_fallback_chain_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/imperative_control.usecase.dart'
    as animated_widgets_animated_barrier_imperative_control_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/scrollable_list.usecase.dart'
    as animated_widgets_animated_barrier_scrollable_list_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_down.usecase.dart'
    as animated_widgets_animated_barrier_slide_down_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_up.usecase.dart'
    as animated_widgets_animated_barrier_slide_up_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_checkbox/animated_checkbox.usecase.dart'
    as animated_widgets_animated_checkbox_animated_checkbox_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/contextual_reveal/contextual_reveal.usecase.dart'
    as animated_widgets_contextual_reveal_contextual_reveal_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/crossfade_widgets/crossfade_widgets.usecase.dart'
    as animated_widgets_crossfade_widgets_crossfade_widgets_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/fade_in_out_view/fade_in_out_view.usecase.dart'
    as animated_widgets_fade_in_out_view_fade_in_out_view_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/fader_widget/fader_widget.usecase.dart'
    as animated_widgets_fader_widget_fader_widget_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_and_fade_widget/grow_and_fade_widget_view.usecase.dart'
    as animated_widgets_grow_and_fade_widget_grow_and_fade_widget_view_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_widget/grow_widget_view.usecase.dart'
    as animated_widgets_grow_widget_grow_widget_view_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/length_colored_border_field/length_colored_border_field.usecase.dart'
    as animated_widgets_length_colored_border_field_length_colored_border_field_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/pill_widget/pill_widget.usecase.dart'
    as animated_widgets_pill_widget_pill_widget_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/pulse_widget/pulse_widget.usecase.dart'
    as animated_widgets_pulse_widget_pulse_widget_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/splash_widget/splash_flow.usecase.dart'
    as animated_widgets_splash_widget_splash_flow_usecase;
import 'package:widgetbook_workspace/packages/animated_widgets/timed_widget/timed_widget.usecase.dart'
    as animated_widgets_timed_widget_timed_widget_usecase;
import 'package:widgetbook_workspace/packages/app_preferences/abstract_preferences_interface.usecase.dart'
    as app_preferences_abstract_preferences_interface_usecase;
import 'package:widgetbook_workspace/packages/app_preferences/hive_init_mode.usecase.dart'
    as app_preferences_hive_init_mode_usecase;
import 'package:widgetbook_workspace/packages/app_preferences/hive_preferences.usecase.dart'
    as app_preferences_hive_preferences_usecase;
import 'package:widgetbook_workspace/packages/app_preferences/mock_preferences.usecase.dart'
    as app_preferences_mock_preferences_usecase;
import 'package:widgetbook_workspace/packages/color_grid/color_grid.usecase.dart'
    as color_grid_color_grid_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/anchored/anchored.usecase.dart'
    as custom_widgets_anchored_anchored_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/crash_screen/crash_screen.usecase.dart'
    as custom_widgets_crash_screen_crash_screen_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/default_welcome_screen/default_welcome_screen.usecase.dart'
    as custom_widgets_default_welcome_screen_default_welcome_screen_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/buttons/directional_slider_and_buttons.usecase.dart'
    as custom_widgets_directional_slider_buttons_directional_slider_and_buttons_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/slider/directional_slider.usecase.dart'
    as custom_widgets_directional_slider_slider_directional_slider_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/expanding_textfield/expanding_textfield.usecase.dart'
    as custom_widgets_expanding_textfield_expanding_textfield_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/ice_chip/ice_chip/ice_chip.usecase.dart'
    as custom_widgets_ice_chip_ice_chip_ice_chip_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/orientation_flex/orientation_flex.usecase.dart'
    as custom_widgets_orientation_flex_orientation_flex_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/sized_spinner/sized_spinner.usecase.dart'
    as custom_widgets_sized_spinner_sized_spinner_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/slide_index_stack/slide_index_stack.usecase.dart'
    as custom_widgets_slide_index_stack_slide_index_stack_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/solid_screen_color/solid_screen_color.usecase.dart'
    as custom_widgets_solid_screen_color_solid_screen_color_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/textfield/input_field.usecase.dart'
    as custom_widgets_textfield_input_field_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/textfield/password_field.usecase.dart'
    as custom_widgets_textfield_password_field_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/button_pair.usecase.dart'
    as custom_widgets_uniform_cluster_button_pair_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/uniform_cluster.usecase.dart'
    as custom_widgets_uniform_cluster_uniform_cluster_usecase;
import 'package:widgetbook_workspace/packages/custom_widgets/uninhertied_text/uninherited_text.usecase.dart'
    as custom_widgets_uninhertied_text_uninherited_text_usecase;
import 'package:widgetbook_workspace/packages/data_grid/data_grid.usecase.dart'
    as data_grid_data_grid_usecase;
import 'package:widgetbook_workspace/packages/extensions/color_ext/color_pair.usecase.dart'
    as extensions_color_ext_color_pair_usecase;
import 'package:widgetbook_workspace/packages/extensions/widget_ext/widget_ext.usecase.dart'
    as extensions_widget_ext_widget_ext_usecase;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picking_lib_src_infinite_scroll_picker_usecase;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as infinite_scroll_picking_settings_settings_screen_usecase;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_button.usecase.dart'
    as rail_navigation_rail_button_usecase;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_button_presets.usecase.dart'
    as rail_navigation_rail_button_presets_usecase;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_overflow_button.usecase.dart'
    as rail_navigation_rail_overflow_button_usecase;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_popover_tile.usecase.dart'
    as rail_navigation_rail_popover_tile_usecase;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_shell.usecase.dart'
    as rail_navigation_rail_shell_usecase;
import 'package:widgetbook_workspace/packages/rail_navigation/rail_widget.usecase.dart'
    as rail_navigation_rail_widget_usecase;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecase.dart'
    as random_color_generator_random_color_generator_usecase;
import 'package:widgetbook_workspace/packages/remind_me/notification_permission_status.usecase.dart'
    as remind_me_notification_permission_status_usecase;
import 'package:widgetbook_workspace/packages/remind_me/remind_me.usecase.dart'
    as remind_me_remind_me_usecase;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_field_usecase;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_popover_usecase;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_date_picker.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_date_picker_usecase;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_time_picker.usecase.dart'
    as scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_time_picker_usecase;
import 'package:widgetbook_workspace/packages/settings_widget/settings_widget.usecase.dart'
    as settings_widget_settings_widget_usecase;
import 'package:widgetbook_workspace/packages/splash_framework/splash_screen.usecase.dart'
    as splash_framework_splash_screen_usecase;
import 'package:widgetbook_workspace/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart'
    as sqlite_viewer_lib_src_widgets_sqlite_viewer_page_sqlite_viewer_page_usecase;
import 'package:widgetbook_workspace/packages/stacking_widgets/stacking_widgets.usecase.dart'
    as stacking_widgets_stacking_widgets_usecase;
import 'package:widgetbook_workspace/packages/theme_framework/settings_screen.usecase.dart'
    as theme_framework_settings_screen_usecase;
import 'package:widgetbook_workspace/packages/theme_framework/theme_mode_card.usecase.dart'
    as theme_framework_theme_mode_card_usecase;
import 'package:widgetbook_workspace/packages/theme_framework/theme_mode_entry.usecase.dart'
    as theme_framework_theme_mode_entry_usecase;
import 'package:widgetbook_workspace/packages/theme_framework/theme_setting_screen.usecase.dart'
    as theme_framework_theme_setting_screen_usecase;
import 'package:widgetbook_workspace/packages/three_d_sphere/three_d_sphere.usecase.dart'
    as three_d_sphere_three_d_sphere_usecase;
import 'package:widgetbook_workspace/packages/widget_animation_framework/animation_combiner_on_widget.usecase.dart'
    as widget_animation_framework_animation_combiner_on_widget_usecase;
import 'package:widgetbook_workspace/packages/widget_animation_framework/animation_controller_widget.usecase.dart'
    as widget_animation_framework_animation_controller_widget_usecase;

final directories = <WidgetbookNode>[
  WidgetbookFolder(
    name: 'analog_clock_widget',
    children: [
      WidgetbookComponent(
        name: 'AnalogClock',
        useCases: [
          WidgetbookUseCase(
            name: 'Face × Hand matrix',
            builder: analog_clock_widget_face_and_hand_matrix_usecase
                .faceAndHandMatrixAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Injected providers (frozen time)',
            builder: analog_clock_widget_injected_providers_usecase
                .injectedProvidersAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: analog_clock_widget_playground_usecase
                .playgroundAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Sizing (radius ladder)',
            builder:
                analog_clock_widget_sizing_usecase.sizingAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Themed presets',
            builder: analog_clock_widget_themed_presets_usecase
                .themedPresetsAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Toggles (numbers × second hand)',
            builder:
                analog_clock_widget_toggles_usecase.togglesAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'World clocks (timezones)',
            builder: analog_clock_widget_timezones_usecase
                .timezonesAnalogClockUseCase,
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
            builder: animated_widgets_animated_barrier_anchored_usecase
                .anchoredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Barrier styling',
            builder: animated_widgets_animated_barrier_barrier_styling_usecase
                .barrierStylingAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'BarrierAnimation playground',
            builder:
                animated_widgets_animated_barrier_animation_playground_usecase
                    .animationPlaygroundAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Centered',
            builder: animated_widgets_animated_barrier_centered_usecase
                .centeredAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Confirm dialog',
            builder: animated_widgets_animated_barrier_confirm_dialog_usecase
                .confirmDialogAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Fallback chain',
            builder: animated_widgets_animated_barrier_fallback_chain_usecase
                .fallbackChainAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Imperative control',
            builder:
                animated_widgets_animated_barrier_imperative_control_usecase
                    .imperativeControlAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Scrollable list popover',
            builder: animated_widgets_animated_barrier_scrollable_list_usecase
                .scrollableListAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide down (from top)',
            builder: animated_widgets_animated_barrier_slide_down_usecase
                .slideDownAnimatedBarrierUseCase,
          ),
          WidgetbookUseCase(
            name: 'Slide up (from bottom)',
            builder: animated_widgets_animated_barrier_slide_up_usecase
                .slideUpAnimatedBarrierUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimatedCheckbox',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_animated_checkbox_animated_checkbox_usecase
                    .animatedCheckboxUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ContextualReveal',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_contextual_reveal_contextual_reveal_usecase
                    .contextualRevealUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CrossFadeWidgets',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                animated_widgets_crossfade_widgets_crossfade_widgets_usecase
                    .crossFadeWidgetsUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FadeInOutView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_fade_in_out_view_fade_in_out_view_usecase
                .fadeInOutViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'FaderWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_fader_widget_fader_widget_usecase
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
                animated_widgets_grow_and_fade_widget_grow_and_fade_widget_view_usecase
                    .growAndFadeWidgetViewUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'GrowWidgetView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_grow_widget_grow_widget_view_usecase
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
                animated_widgets_length_colored_border_field_length_colored_border_field_usecase
                    .lengthColoredBorderFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PillWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_pill_widget_pill_widget_usecase
                .buildPillWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PulseWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_pulse_widget_pulse_widget_usecase
                .buildPulseWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SplashScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Splash ends after tasks (no spinner)',
            builder: animated_widgets_splash_widget_splash_flow_usecase
                .buildSplashFlowNoSpinnerUseCase,
          ),
          WidgetbookUseCase(
            name: 'Splash ends before tasks (spinner shown)',
            builder: animated_widgets_splash_widget_splash_flow_usecase
                .buildSplashFlowSpinnerShownUseCase,
          ),
          WidgetbookUseCase(
            name: 'Task error',
            builder: animated_widgets_splash_widget_splash_flow_usecase
                .buildSplashFlowTaskErrorUseCase,
          ),
          WidgetbookUseCase(
            name: 'Tasks time out',
            builder: animated_widgets_splash_widget_splash_flow_usecase
                .buildSplashFlowTimeoutUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TimedWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: animated_widgets_timed_widget_timed_widget_usecase
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
            builder: app_preferences_abstract_preferences_interface_usecase
                .abstractPreferencesContractAbsent,
          ),
          WidgetbookUseCase(
            name: 'Contract — structural ops',
            builder: app_preferences_abstract_preferences_interface_usecase
                .abstractPreferencesContractStructural,
          ),
          WidgetbookUseCase(
            name: 'Contract — type filtering',
            builder: app_preferences_abstract_preferences_interface_usecase
                .abstractPreferencesContractTyping,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HiveInitModeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Overview',
            builder:
                app_preferences_hive_init_mode_usecase.hiveInitModeOverview,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HivePreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: app_preferences_hive_preferences_usecase
                .hivePreferencesPlayground,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MockPreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: app_preferences_mock_preferences_usecase
                .mockPreferencesPlayground,
          ),
          WidgetbookUseCase(
            name: 'Test helpers',
            builder: app_preferences_mock_preferences_usecase
                .mockPreferencesTestHelpers,
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
            builder: color_grid_color_grid_usecase.buildColorGridUseCase,
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
            builder: custom_widgets_anchored_anchored_usecase.anchoredUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ButtonPair',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_uniform_cluster_button_pair_usecase
                .buttonPairUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CrashScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_crash_screen_crash_screen_usecase
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
                custom_widgets_default_welcome_screen_default_welcome_screen_usecase
                    .buildDefaultWelcomeScreenUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DirectionalSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                custom_widgets_directional_slider_slider_directional_slider_usecase
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
                custom_widgets_directional_slider_buttons_directional_slider_and_buttons_usecase
                    .directionalSliderAndButtonsUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ExpandingTextField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                custom_widgets_expanding_textfield_expanding_textfield_usecase
                    .expandingTextFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'IceChip',
        useCases: [
          WidgetbookUseCase(
            name: 'Default (widget child)',
            builder: custom_widgets_ice_chip_ice_chip_ice_chip_usecase
                .buildIceChipDefaultUseCase,
          ),
          WidgetbookUseCase(
            name: 'Text',
            builder: custom_widgets_ice_chip_ice_chip_ice_chip_usecase
                .buildIceChipTextUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'InputField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_textfield_input_field_usecase
                .buildInputFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'OrientationFlex',
        useCases: [
          WidgetbookUseCase(
            name: 'Login / Register',
            builder: custom_widgets_orientation_flex_orientation_flex_usecase
                .buildOrientationFlexUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PasswordField',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_textfield_password_field_usecase
                .buildPasswordFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SizedSpinner',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_sized_spinner_sized_spinner_usecase
                .buildSizedSpinnerUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SlideIndexedStack',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_slide_index_stack_slide_index_stack_usecase
                .buildSlideIndexedStackUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SolidScreenColor',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder:
                custom_widgets_solid_screen_color_solid_screen_color_usecase
                    .buildSolidScreenColorUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'UniformCluster',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_uniform_cluster_uniform_cluster_usecase
                .uniformClusterUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'UninheritedText',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: custom_widgets_uninhertied_text_uninherited_text_usecase
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
            builder: data_grid_data_grid_usecase.buildDataGridUseCase,
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
            builder:
                extensions_color_ext_color_pair_usecase.buildColorPairUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Widget',
        useCases: [
          WidgetbookUseCase(
            name: 'Widget Extensions',
            builder:
                extensions_widget_ext_widget_ext_usecase.buildWidgetExtUseCase,
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
            builder:
                infinite_scroll_picking_lib_src_infinite_scroll_picker_usecase
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
            builder: infinite_scroll_picking_settings_settings_screen_usecase
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
            builder: rail_navigation_rail_button_presets_usecase
                .buildMainRailButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MoreRailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_button_presets_usecase
                .buildMoreRailButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_button_usecase.buildRailButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailOverflowButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_overflow_button_usecase
                .buildRailOverflowButtonUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailPopoverTile',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_popover_tile_usecase
                .buildRailPopoverTileUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailShell',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_shell_usecase.buildRailShellUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RailWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_widget_usecase.buildRailWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SettingsRailButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: rail_navigation_rail_button_presets_usecase
                .buildSettingsRailButtonUseCase,
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
            builder: random_color_generator_random_color_generator_usecase
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
            builder: remind_me_notification_permission_status_usecase
                .notificationPermissionStatusOverview,
          ),
          WidgetbookUseCase(
            name: 'State picker',
            builder: remind_me_notification_permission_status_usecase
                .notificationPermissionStatusPicker,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RemindMeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'API reference',
            builder: remind_me_remind_me_usecase.remindMeApiReference,
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
                scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_field_usecase
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
                scrolling_datetime_pickers_lib_src_presentation_widgets_datetime_popover_datetime_picker_popover_usecase
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
                scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_date_picker_usecase
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
                scrolling_datetime_pickers_lib_src_presentation_widgets_scrolling_time_picker_usecase
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
            builder:
                settings_widget_settings_widget_usecase.settingsWidgetUseCase,
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
            builder:
                splash_framework_splash_screen_usecase.buildSplashScreenUseCase,
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
                sqlite_viewer_lib_src_widgets_sqlite_viewer_page_sqlite_viewer_page_usecase
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
            builder: stacking_widgets_stacking_widgets_usecase
                .buildStackingWidgetsUseCase,
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
            builder: theme_framework_settings_screen_usecase
                .buildSettingsScreenUseCase,
          ),
          WidgetbookUseCase(
            name: 'With theme',
            builder: theme_framework_settings_screen_usecase
                .buildSettingsScreenWithThemeUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeModeCard',
        useCases: [
          WidgetbookUseCase(
            name: 'Controlled',
            builder: theme_framework_theme_mode_card_usecase
                .buildThemeModeCardUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeModeEntry',
        useCases: [
          WidgetbookUseCase(
            name: 'Live',
            builder: theme_framework_theme_mode_entry_usecase
                .buildThemeModeEntryUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ThemeSettingScreen',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: theme_framework_theme_setting_screen_usecase
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
            builder:
                three_d_sphere_three_d_sphere_usecase.buildThreeDSphereUseCase,
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
            builder:
                widget_animation_framework_animation_combiner_on_widget_usecase
                    .buildAnimationCombinerOnWidgetUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AnimationControllerWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Play on mount',
            builder:
                widget_animation_framework_animation_controller_widget_usecase
                    .buildAnimationControllerWidgetUseCase,
          ),
        ],
      ),
    ],
  ),
];
