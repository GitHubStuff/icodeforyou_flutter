// lib/src/widget/_internal.dart

import 'dart:async';

import 'package:animated_rail_menu/src/cubit/rail_menu_cubit.dart';
import 'package:animated_rail_menu/src/cubit/rail_menu_state.dart';
import 'package:animated_rail_menu/src/model/haptic_intensity.dart';
import 'package:animated_rail_menu/src/model/menu_icon_spacing.dart';
import 'package:animated_rail_menu/src/model/rail_direction.dart';
import 'package:animated_rail_menu/src/model/rail_icon.dart';
import 'package:animated_rail_menu/src/model/rail_menu_entry.dart';
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:animated_rail_menu/src/theme/rail_menu_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '_body_switcher.dart';
part '_elevator_rail.dart';
part '_horizontal_rail.dart';
part '_more_bottom_sheet.dart';
part '_more_inline.dart';
part '_overflow_calculator.dart';
part '_rail_item_tile.dart';
part 'rail_navigation_widget.dart';
