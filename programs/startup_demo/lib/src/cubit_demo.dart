// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:ui' show RootIsolateToken;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show BackgroundIsolateBinaryMessenger;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_logger/my_logger.dart' show MyLogger;
import 'package:service_locator/service_locator.dart'
    show
        GetItServiceLocator,
        LazyAsyncServiceDescriptor,
        ServiceClass,
        ServiceItemTimeout,
        ServiceLocatorRegistry;
import 'package:since_when/since_when.dart' show SinceWhenDatabase;
import 'package:theme_service/theme_service.dart';

const TextStyle style = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

final ServiceLocatorRegistry _sl = ServiceLocatorRegistry(
  locator: GetItServiceLocator(),
);

class CubitDemo extends StatelessWidget {
  const CubitDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ThemeService>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.toString(), style: style),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _onTap,
              child: const Text('Check State', style: style),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap() async {
    const ds = SinceWhenDescriptor();
    MyLogger.d(ds);
    _sl.stage(ds);

    MyLogger.d(_sl);

    await _sl.register('SinceWhen');
    MyLogger.d(_sl);

    final db = await _sl.getAsync<SinceWhenServiceClass>('SinceWhen');
    MyLogger.d(db, tag: '💾');
    MyLogger.t(_sl);
  }
}

class SinceWhenServiceClass implements ServiceClass {
  SinceWhenServiceClass(this.db);
  final SinceWhenDatabase db;
}

class SinceWhenDescriptor
    extends LazyAsyncServiceDescriptor<SinceWhenServiceClass> {
  const SinceWhenDescriptor();

  @override
  String get name => 'SinceWhen';

  @override
  List<Type> get dependencies => const [];

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<SinceWhenServiceClass> Function() get builder => () async {
    final RootIsolateToken token = RootIsolateToken.instance!;

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    try {
      final result = await SinceWhenDatabase.open().timeout(timeout);
      final db = result.getOrElse((failure) => throw Exception(failure));
      return SinceWhenServiceClass(db);
    } on TimeoutException {
      throw ServiceItemTimeout(name, timeout);
    }
  };
}
