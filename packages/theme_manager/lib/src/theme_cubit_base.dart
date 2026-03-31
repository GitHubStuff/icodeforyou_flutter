// lib/src/theme_cubit_base.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ThemeCubitBase extends Cubit<ThemeMode> {
  ThemeCubitBase(super.initialState);

  ThemeData get dark;
  ThemeData get light;

  void toLight();
  void toDark();
  void toSystem();
}
