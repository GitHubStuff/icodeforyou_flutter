// dart format width=80
// ignore_for_file: depend_on_referenced_packages, directives_ordering

// Hand-ordered Widgetbook directories.
// Source of truth: main.directories.g.dart (generated). This file applies
// the workspace convention: one WidgetbookFolder per package, alphabetical,
// with the generator's intermediate (src/lib/presentation/widgets) folders
// collapsed away. Re-derive from the generated file when use cases change.

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_workspace/packages/analog_clock_widget/face_and_hand_matrix.usecase.dart'
    as analog_face_and_hand;
import 'package:widgetbook_workspace/packages/analog_clock_widget/injected_providers.usecase.dart'
    as analog_injected;
import 'package:widgetbook_workspace/packages/analog_clock_widget/playground.usecase.dart'
    as analog_playground;
import 'package:widgetbook_workspace/packages/analog_clock_widget/sizing.usecase.dart'
    as analog_sizing;
import 'package:widgetbook_workspace/packages/analog_clock_widget/themed_presets.usecase.dart'
    as analog_themed;
import 'package:widgetbook_workspace/packages/analog_clock_widget/timezones.usecase.dart'
    as analog_timezones;
import 'package:widgetbook_workspace/packages/analog_clock_widget/toggles.usecase.dart'
    as analog_toggles;
import 'package:widgetbook_workspace/packages/animated_rail_menu/animated_rail_menu_widget.usecase.dart'
    as animated_rail_menu;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/anchored.usecase.dart'
    as barrier_anchored;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/animation_playground.usecase.dart'
    as barrier_playground;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/barrier_styling.usecase.dart'
    as barrier_styling;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/centered.usecase.dart'
    as barrier_centered;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/confirm_dialog.usecase.dart'
    as barrier_confirm;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/fallback_chain.usecase.dart'
    as barrier_fallback;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/imperative_control.usecase.dart'
    as barrier_imperative;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/scrollable_list.usecase.dart'
    as barrier_scrollable;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_down.usecase.dart'
    as barrier_slide_down;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_barrier/slide_up.usecase.dart'
    as barrier_slide_up;
import 'package:widgetbook_workspace/packages/animated_widgets/animated_checkbox/animated_checkbox.usecase.dart'
    as animated_checkbox;
import 'package:widgetbook_workspace/packages/animated_widgets/comination_animation/combination_animation.usecase.dart'
    as combination_animation;
import 'package:widgetbook_workspace/packages/animated_widgets/contextual_reveal/src/contextual_reveal.usecase.dart'
    as contextual_reveal;
import 'package:widgetbook_workspace/packages/animated_widgets/crossfade_widgets/crossfade_widgets.usecase.dart'
    as crossfade_widgets;
import 'package:widgetbook_workspace/packages/animated_widgets/fade_in_out_view/fade_in_out_view.usecase.dart'
    as fade_in_out_view;
import 'package:widgetbook_workspace/packages/animated_widgets/fader_widget/src/fader_widget.usecase.dart'
    as fader_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_and_fade_widget/grow_and_fade_widget_view.usecase.dart'
    as grow_and_fade_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/grow_widget/grow_widget_view.usecase.dart'
    as grow_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/length_colored_border_field/length_colored_border_field.usecase.dart'
    as length_colored_border_field;
import 'package:widgetbook_workspace/packages/animated_widgets/pulse_widget/pulse_widget.usecase.dart'
    as pulse_widget;
import 'package:widgetbook_workspace/packages/animated_widgets/splash_widget/splash_flow.usecase.dart'
    as splash_flow;
import 'package:widgetbook_workspace/packages/animated_widgets/timed_widget/timed_widget.usecase.dart'
    as timed_widget;
import 'package:widgetbook_workspace/packages/app_preferences/abstract_preferences_interface.usecase.dart'
    as app_prefs_abstract;
import 'package:widgetbook_workspace/packages/app_preferences/hive_init_mode.usecase.dart'
    as app_prefs_hive_init;
import 'package:widgetbook_workspace/packages/app_preferences/hive_preferences.usecase.dart'
    as app_prefs_hive;
import 'package:widgetbook_workspace/packages/app_preferences/mock_preferences.usecase.dart'
    as app_prefs_mock;
import 'package:widgetbook_workspace/packages/custom_widgets/anchored/anchored.usecase.dart'
    as cw_anchored;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/buttons/directional_slider_and_buttons.usecase.dart'
    as cw_directional_buttons;
import 'package:widgetbook_workspace/packages/custom_widgets/directional_slider/slider/directional_slider.usecase.dart'
    as cw_directional_slider;
import 'package:widgetbook_workspace/packages/custom_widgets/expanding_textfield/expanding_textfield.usecase.dart'
    as cw_expanding_textfield;
import 'package:widgetbook_workspace/packages/custom_widgets/full_screen_color/full_screen_color.usecase.dart'
    as cw_full_screen_color;
import 'package:widgetbook_workspace/packages/custom_widgets/sized_spinner/sized_spinner.usecase.dart'
    as cw_sized_spinner;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/button_pair.usecase.dart'
    as cw_button_pair;
import 'package:widgetbook_workspace/packages/custom_widgets/uniform_cluster/uniform_cluster.usecase.dart'
    as cw_uniform_cluster;
import 'package:widgetbook_workspace/packages/custom_widgets/uninhertied_text/uninherited_text.usecase.dart'
    as cw_uninherited_text;
import 'package:widgetbook_workspace/packages/extensions/datetime_ext/datetime_delta_text.usecase.dart'
    as ext_datetime_delta;
import 'package:widgetbook_workspace/packages/extensions/widget_ext/widget_ext.usecase.dart'
    as ext_widget;
import 'package:widgetbook_workspace/packages/ice_chips/lib/src/ice_chip_tray/ice_chip_tray.usecase.dart'
    as ice_chip_tray;
import 'package:widgetbook_workspace/packages/ice_chips/lib/src/ice_chip_widget/ice_chip.usecase.dart'
    as ice_chip;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart'
    as infinite_scroll_picker;
import 'package:widgetbook_workspace/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart'
    as infinite_scroll_settings;
import 'package:widgetbook_workspace/packages/random_color_generator/random_color_generator.usecase.dart'
    as random_color_generator;
import 'package:widgetbook_workspace/packages/remind_me/notification_permission_status.usecase.dart'
    as remind_me_permission;
import 'package:widgetbook_workspace/packages/remind_me/remind_me.usecase.dart'
    as remind_me;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field.usecase.dart'
    as sdp_field;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.usecase.dart'
    as sdp_popover;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_date_picker.usecase.dart'
    as sdp_date_picker;
import 'package:widgetbook_workspace/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_time_picker.usecase.dart'
    as sdp_time_picker;
import 'package:widgetbook_workspace/packages/settings_widget/settings_widget.usecase.dart'
    as settings_widget;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_edit_screen.usecase.dart'
    as sww_tag_glossary_edit;
import 'package:widgetbook_workspace/packages/since_when_widgets/tag_glossary_read_view.usecase.dart'
    as sww_tag_glossary_read;
import 'package:widgetbook_workspace/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart'
    as sqlite_viewer_page;
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
            builder: analog_face_and_hand.faceAndHandMatrixAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Injected providers (frozen time)',
            builder: analog_injected.injectedProvidersAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: analog_playground.playgroundAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Sizing (radius ladder)',
            builder: analog_sizing.sizingAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Themed presets',
            builder: analog_themed.themedPresetsAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'Toggles (numbers × second hand)',
            builder: analog_toggles.togglesAnalogClockUseCase,
          ),
          WidgetbookUseCase(
            name: 'World clocks (timezones)',
            builder: analog_timezones.timezonesAnalogClockUseCase,
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
      WidgetbookFolder(
        name: 'animated_barrier',
        children: [
          WidgetbookComponent(
            name: 'AnimatedBarrier',
            useCases: [
              WidgetbookUseCase(
                name: 'Anchored to button',
                builder: barrier_anchored.anchoredAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Animation playground',
                builder: barrier_playground.animationPlaygroundAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Barrier styling',
                builder: barrier_styling.barrierStylingAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Centered',
                builder: barrier_centered.centeredAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Confirm dialog',
                builder: barrier_confirm.confirmDialogAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Fallback chain',
                builder: barrier_fallback.fallbackChainAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Imperative control',
                builder: barrier_imperative.imperativeControlAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Scrollable list popover',
                builder: barrier_scrollable.scrollableListAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Slide down (from top)',
                builder: barrier_slide_down.slideDownAnimatedBarrierUseCase,
              ),
              WidgetbookUseCase(
                name: 'Slide up (from bottom)',
                builder: barrier_slide_up.slideUpAnimatedBarrierUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'animated_checkbox',
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
        ],
      ),
      WidgetbookFolder(
        name: 'combination_animation',
        children: [
          WidgetbookComponent(
            name: 'CombinationAnimation',
            useCases: [
              WidgetbookUseCase(
                name: 'Chained x3 (parallel)',
                builder: combination_animation.buildCombinationAnimationChainedUseCase,
              ),
              WidgetbookUseCase(
                name: 'Single',
                builder: combination_animation.buildCombinationAnimationSingleUseCase,
              ),
            ],
          ),
          WidgetbookComponent(
            name: 'CombinationAnimationSequenced',
            useCases: [
              WidgetbookUseCase(
                name: 'Sequenced x3',
                builder: combination_animation.buildCombinationAnimationSequencedUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'contextual_reveal',
        children: [
          WidgetbookComponent(
            name: 'ContextualReveal',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: contextual_reveal.contextualRevealUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'crossfade_widgets',
        children: [
          WidgetbookComponent(
            name: 'CrossFadeWidgets',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: crossfade_widgets.crossFadeWidgetsUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'fade_in_out_view',
        children: [
          WidgetbookComponent(
            name: 'FadeInOutView',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: fade_in_out_view.fadeInOutViewUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'fader_widget',
        children: [
          WidgetbookComponent(
            name: 'FaderWidget',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: fader_widget.faderWidgetUseCase,
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
                builder: grow_and_fade_widget.growAndFadeWidgetViewUseCase,
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
                builder: grow_widget.growWidgetViewUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'length_colored_border_field',
        children: [
          WidgetbookComponent(
            name: 'LengthColoredBorderField',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: length_colored_border_field.lengthColoredBorderFieldUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'pulse_widget',
        children: [
          WidgetbookComponent(
            name: 'PulseWidget',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: pulse_widget.buildPulseWidgetUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'splash_widget',
        children: [
          WidgetbookComponent(
            name: 'SplashFlow',
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
        ],
      ),
      WidgetbookFolder(
        name: 'timed_widget',
        children: [
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
            builder: app_prefs_abstract.abstractPreferencesContractAbsent,
          ),
          WidgetbookUseCase(
            name: 'Contract — structural ops',
            builder: app_prefs_abstract.abstractPreferencesContractStructural,
          ),
          WidgetbookUseCase(
            name: 'Contract — type filtering',
            builder: app_prefs_abstract.abstractPreferencesContractTyping,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HiveInitModeShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Overview',
            builder: app_prefs_hive_init.hiveInitModeOverview,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'HivePreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: app_prefs_hive.hivePreferencesPlayground,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MockPreferencesShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: app_prefs_mock.mockPreferencesPlayground,
          ),
          WidgetbookUseCase(
            name: 'Test helpers',
            builder: app_prefs_mock.mockPreferencesTestHelpers,
          ),
        ],
      ),
    ],
  ),

  // ─── custom_widgets ──────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'custom_widgets',
    children: [
      WidgetbookFolder(
        name: 'anchored',
        children: [
          WidgetbookComponent(
            name: 'Anchored',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_anchored.anchoredUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'directional_slider',
        children: [
          WidgetbookComponent(
            name: 'DirectionalSlider',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_directional_slider.directionalSliderUseCase,
              ),
            ],
          ),
          WidgetbookComponent(
            name: 'DirectionalSliderAndButtons',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_directional_buttons.directionalSliderAndButtonsUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'expanding_textfield',
        children: [
          WidgetbookComponent(
            name: 'ExpandingTextField',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_expanding_textfield.expandingTextFieldUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'full_screen_color',
        children: [
          WidgetbookComponent(
            name: 'FullScreenColor',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_full_screen_color.buildFullScreenColorUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'sized_spinner',
        children: [
          WidgetbookComponent(
            name: 'SizedSpinner',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_sized_spinner.buildSizedSpinnerUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'uniform_cluster',
        children: [
          WidgetbookComponent(
            name: 'ButtonPair',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_button_pair.buttonPairUseCase,
              ),
            ],
          ),
          WidgetbookComponent(
            name: 'UniformCluster',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_uniform_cluster.uniformClusterUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'uninherited_text',
        children: [
          WidgetbookComponent(
            name: 'UninheritedText',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: cw_uninherited_text.buildUninheritedTextUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),

  // ─── extensions ──────────────────────────────────────────────────────────
  WidgetbookFolder(
    name: 'extensions',
    children: [
      WidgetbookFolder(
        name: 'datetime_ext',
        children: [
          WidgetbookComponent(
            name: 'DateTimeDeltaText',
            useCases: [
              WidgetbookUseCase(
                name: 'Default',
                builder: ext_datetime_delta.buildDateTimeDeltaTextUseCase,
              ),
            ],
          ),
        ],
      ),
      WidgetbookFolder(
        name: 'widget_ext',
        children: [
          WidgetbookComponent(
            name: 'Widget',
            useCases: [
              WidgetbookUseCase(
                name: 'Widget Extensions',
                builder: ext_widget.buildWidgetExtUseCase,
              ),
            ],
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
            builder: infinite_scroll_settings.settingsScreenUseCase,
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
            builder: remind_me_permission.notificationPermissionStatusOverview,
          ),
          WidgetbookUseCase(
            name: 'State picker',
            builder: remind_me_permission.notificationPermissionStatusPicker,
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
            builder: sdp_field.dateTimePickerFieldUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'DateTimePickerPopoverShowcase',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sdp_popover.dateTimePickerPopoverUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ScrollingDatePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sdp_date_picker.scrollingDatePickerUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ScrollingTimePicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sdp_time_picker.scrollingTimePickerUseCase,
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
            builder: sww_tag_glossary_edit.tagGlossaryEditScreenUseCase,
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'TagGlossaryReadView',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: sww_tag_glossary_read.tagGlossaryReadViewUseCase,
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
