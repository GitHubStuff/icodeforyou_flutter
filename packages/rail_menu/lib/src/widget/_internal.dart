// packages/rail_menu/lib/src/widget/_internal.dart

import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rail_menu/src/cubit/rail_menu_cubit.dart';
import 'package:rail_menu/src/model/rail_menu_dimensions.dart';
import 'package:rail_menu/src/model/rail_menu_direction.dart';
import 'package:rail_menu/src/model/rail_menu_item.dart';

part '_tile_config.dart';
part '_overflow_calculator.dart';
part '_tap_interceptor.dart';
part '_more_modal_content.dart';
part '_more_modal.dart';
part '_menu_item_tile.dart';
part '_horizontal_menu_bar.dart';
part '_vertical_menu_bar.dart';
part '_menu_bar_router.dart';
part '_menu_layout.dart';
part 'rail_menu_widget.dart';
