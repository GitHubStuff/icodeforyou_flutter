// test/src/app/startup_task_test.dart

import 'package:application_setup/src/app/startup_task.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTask extends StartupTask {
  const _FakeTask();

  @override
  String get id => 'fake_task';

  @override
  Future<void> run() async {}
}

class _ThrowingTask extends StartupTask {
  const _ThrowingTask();

  @override
  String get id => 'throwing_task';

  @override
  Future<void> run() async => throw Exception('task failed');
}

void main() {
  group('StartupTask', () {
    test('id returns correct identifier', () {
      expect(const _FakeTask().id, 'fake_task');
    });

    test('run completes without error', () async {
      await expectLater(const _FakeTask().run(), completes);
    });

    test('run can throw', () async {
      await expectLater(
        const _ThrowingTask().run(),
        throwsException,
      );
    });
  });
}
