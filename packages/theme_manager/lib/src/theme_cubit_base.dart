// lib/src/theme_cubit_base.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ThemeCubitBase extends Cubit<ThemeMode> {
  ThemeCubitBase(super.initialState);

  void toLight();
  void toDark();
  void toSystem();
}
