// theme_cubit.dart
// ignore_for_file: omit_local_variable_types
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nosql/nosql.dart' show NoSqlDBAbstract, NoSqlBoxAbstract;

part 'theme_state.dart';

const String _containerName = 'theme_mgr_pkg_b8f4c2e9d1a7f5b3';

class ThemeCubit<T extends NoSqlDBAbstract> extends Cubit<ThemeState> {
  // Private constructor
  ThemeCubit._internal({required T nosqlDB})
    : _db = nosqlDB,
      super(ThemeState.initial);

  final T _db;
  late final NoSqlBoxAbstract<String> _box;

  // Public factory constructor - this ensures _setup() completes first
  static Future<ThemeCubit<T>> create<T extends NoSqlDBAbstract>({
    required T nosqlDB,
  }) async {
    final ThemeCubit<T> cubit = ThemeCubit<T>._internal(nosqlDB: nosqlDB);
    await cubit._setup();
    return cubit;
  }

  Future<void> _setup() async {
    final NoSqlBoxAbstract<String>? box = await _db.openBox<String>(
      _containerName,
    );
    if (box == null) {
      throw Exception('Invalid state for NoSqlBox');
    }
    _box = box;

    final String? savedTheme = await _box.get(
      _containerName,
      defaultValue: ThemeMode.system.name,
    );
    emit(ThemeState.from(name: savedTheme!));
  }

  Brightness get brightness => state.brightness;

  void setTheme(ThemeMode mode) {
    _box.put(_containerName, mode.name);
    emit(ThemeState.from(name: mode.name));
  }
}
