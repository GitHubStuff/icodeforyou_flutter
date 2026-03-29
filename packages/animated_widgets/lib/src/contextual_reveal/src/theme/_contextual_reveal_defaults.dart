// animated_widgets/lib/src/contextual_reveal/contextual_reveal_defaults.dart
import 'package:flutter/material.dart';

/// Duration of the fade-in transition when the popover appears.
const kFadeInDuration = Duration(milliseconds: 200);

/// Duration of the fade-out transition when the popover dismisses.
const kFadeOutDuration = Duration(milliseconds: 250);

/// How long the popover remains fully visible before fading out.
const kShowDuration = Duration(milliseconds: 750);

/// Gap in logical pixels between the target widget and the popover.
const kPopoverGap = 8.0;

/// Barrier color used in light mode.
const kLightBarrierColor = Color.fromARGB(175, 255, 255, 255);

/// Popover background color used in light mode.
const kLightPopoverBackground = Color(0x00000000);

/// Barrier color used in dark mode.
const kDarkBarrierColor = Color.fromARGB(175, 0, 0, 0);

/// Popover background color used in dark mode.
const kDarkPopoverBackground = Color(0x00000000);
