// test/src/app/app_cubit_base_test.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppCubitBase', () {
    test('initial state is AppInitializing', () async {
      final cubit = AppCubit(
        tasks: const [],
        computeTask: (fn, t) => fn(t),
      );
      expect(cubit.state, isA<AppInitializing>());
      await cubit.close();
    });

    test('initial state is AppInitializing with tasks', () async {
      final cubit = AppCubit(
        tasks: [_StubTask()],
        computeTask: (fn, t) => fn(t),
      );
      expect(cubit.state, isA<AppInitializing>());
      await cubit.close();
    });
  });
}

class _StubTask extends StartupTask {
  @override
  String get id => 'stub';

  @override
  Future<void> run() async {}
}
