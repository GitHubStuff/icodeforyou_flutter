import 'dart:async';

import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart'
    show ServiceClass, AsyncServiceDescriptor, ServiceItemTimeout;
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, SharedThemePersistence, MaterialTheme;

class ThemeService implements ServiceClass {
  ThemeService(this.themeCubit);
  final MaterialThemeCubit themeCubit;
}

//+
class ThemeDescriptor extends AsyncServiceDescriptor<ThemeService> {
  ThemeDescriptor({required this.name, this.dark, this.light});

  ThemeData? dark;
  ThemeData? light;

  @override
  final String name;

  @override
  List<Type> get dependencies => const [];

  @override
  Duration get timeout => const Duration(milliseconds: 100);

  @override
  Future<ThemeService> Function() get builder => () async {
    late final SharedThemePersistence store;

    try {
      store = await SharedThemePersistence.create().timeout(timeout);
    } on TimeoutException {
      throw ServiceItemTimeout(name, timeout);
    }

    final mode = store.load();
    final MaterialTheme theme = MaterialTheme(
      mode: mode,
      dark: dark,
      light: light,
    );
    final cubit = MaterialThemeCubit(theme: theme, themeModeStorage: store);
    return ThemeService(cubit);
  };
}
