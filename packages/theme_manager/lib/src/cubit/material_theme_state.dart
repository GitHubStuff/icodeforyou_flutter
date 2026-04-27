// ignore_for_file: public_member_api_docs


import 'package:flutter/material.dart';

abstract interface class MaterialThemeState {
  ThemeMode get mode;
  ThemeData get dark;
  ThemeData get light;
  MaterialThemeState copyWith({
    ThemeMode? mode,
    ThemeData? dark,
    ThemeData? light,
  });
}

