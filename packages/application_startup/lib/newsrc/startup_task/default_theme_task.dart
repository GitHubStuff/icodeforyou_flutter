// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/startup_task/base_service_item.dart';
import 'package:flutter/material.dart' show ThemeData;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase;
import 'package:theme_manager/theme_manager.dart';

class DefaultThemeTask extends BaseServiceItem {
  DefaultThemeTask({
    required this.darkTheme,
    required this.lightTheme,
    required super.serviceDispatcher,
    required super.registrar,
  });

  final ThemeData darkTheme;
  final ThemeData lightTheme;

  @override
  FutureOr<BlocBase<Object?>> create() =>
      DefaultThemeCubit.create(darkTheme: darkTheme, lightTheme: lightTheme);

  @override
  String get name => 'DefaultThemeTask';

  @override
  AsyncTaskRunMode get startupTaskRunMode => AsyncTaskRunMode.root;

  @override
  Duration get timeout => const Duration(milliseconds: 250);
}
