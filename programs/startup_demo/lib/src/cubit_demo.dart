// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_logger/my_logger.dart' show MyLogger;
import 'package:service_locator/service_locator.dart'
    show EagerSync, LazyAsync, Registry, ServiceClass, ServicesStateManagerCubit;

const TextStyle style = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

class CubitDemo extends StatelessWidget {
  const CubitDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ServicesStateManagerCubit>().state;
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
    final DatabaseServiceDescriptor databaseServiceDescriptor =
        DatabaseServiceDescriptor();
    MyLogger.i(databaseServiceDescriptor);
    final BrightnessServiceDescriptor brightnessServiceDescriptor =
        BrightnessServiceDescriptor();
    MyLogger.i(brightnessServiceDescriptor);

    final registry = Registry.R;
  }
}

//-
final class DatabaseServiceDescriptor extends LazyAsync<DatabaseService> {
  @override
  Future<DatabaseService> Function() get factory => DatabaseService.create;

  @override
  final List<String> dependencies = ['BrightnessService'];
}

final class DatabaseService implements ServiceClass {
  const DatabaseService();
  static Future<DatabaseService> create() async => const DatabaseService();
}
//-

final class BrightnessServiceDescriptor extends EagerSync<BrightnessService> {
  @override
  BrightnessService instance = BrightnessService();
}

final class BrightnessService implements ServiceClass {}
