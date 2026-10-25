// packages/spinners/test/src/spin_widget/spin_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:spinners/spinners.dart' show SpinController;

void main() {
  group('SpinController', () {
    late SpinController controller;
    late int notifications;

    setUp(() {
      controller = SpinController();
      notifications = 0;
      controller.addListener(() => notifications++);
    });

    tearDown(() => controller.dispose());

    group('constructor', () {
      test('defaults to 1 rpm clockwise, stopped at 0°', () {
        expect(controller.rpm, 1);
        expect(controller.isClockwise, isTrue);
        expect(controller.isSpinning, isFalse);
        expect(controller.angle, 0);
        expect(controller.turns, 0);
        expect(controller.startAngle, 0);
        expect(controller.epoch, 0);
      });

      test('accepts a negative rpm as counter-clockwise', () {
        final ccw = SpinController(rpm: -3);
        addTearDown(ccw.dispose);
        expect(ccw.rpm, -3);
        expect(ccw.isClockwise, isFalse);
      });

      test('asserts on zero rpm', () {
        expect(() => SpinController(rpm: 0), throwsAssertionError);
      });
    });

    group('rpm', () {
      test('setting the same value is a no-op', () {
        controller.rpm = 1;
        expect(notifications, 0);
        expect(controller.epoch, 0);
      });

      test('setting a new value while stopped notifies without rebasing', () {
        controller.rpm = 2;
        expect(controller.rpm, 2);
        expect(notifications, 1);
        expect(controller.epoch, 0);
      });

      test('setting a new value while spinning rebases to the live angle', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start();
        elapsed = 0.25;
        expect(controller.angle, 90);
        notifications = 0;

        controller.rpm = 2;
        // The widget restarts its animation from zero on a new epoch.
        elapsed = 0;

        expect(controller.rpm, 2);
        expect(controller.epoch, 2);
        expect(controller.angle, 90);
        expect(notifications, 1);
      });

      test('asserts on zero', () {
        expect(() => controller.rpm = 0, throwsAssertionError);
      });
    });

    group('period', () {
      test('is one minute divided by |rpm|', () {
        controller.rpm = 60;
        expect(controller.period, const Duration(seconds: 1));

        controller.rpm = -120;
        expect(controller.period, const Duration(milliseconds: 500));
      });
    });

    group('turns and angle', () {
      test('return the base position while stopped', () {
        controller.reset(angle: 180);
        expect(controller.turns, 0.5);
        expect(controller.angle, 180);
      });

      test('treat a missing attachment as zero elapsed while spinning', () {
        controller.start(angle: 90);
        expect(controller.isSpinning, isTrue);
        expect(controller.turns, 0.25);
        expect(controller.angle, 90);
      });

      test('advance clockwise with the attached elapsed turns', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start(angle: 90);
        elapsed = 0.5;
        expect(controller.turns, 0.75);
        expect(controller.angle, 270);
      });

      test('advance counter-clockwise for a negative rpm', () {
        var elapsed = 0.0;
        controller
          ..rpm = -1
          ..attach(() => elapsed)
          ..start();
        elapsed = 0.25;
        expect(controller.turns, 0.75);
        expect(controller.angle, 270);
      });

      test('wrap modulo one full revolution', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start(angle: 270);
        elapsed = 1.5;
        expect(controller.turns, moreOrLessEquals(0.25));
        expect(controller.angle, moreOrLessEquals(90));
      });
    });

    group('start', () {
      test('spins from the normalised angle and bumps the epoch', () {
        controller.start(angle: 450);
        expect(controller.isSpinning, isTrue);
        expect(controller.startAngle, 90);
        expect(controller.angle, 90);
        expect(controller.epoch, 1);
        expect(notifications, 1);
      });

      test('normalises a negative angle', () {
        controller.start(angle: -90);
        expect(controller.startAngle, 270);
        expect(controller.angle, 270);
      });

      test('defaults to 0°', () {
        controller
          ..reset(angle: 45)
          ..start();
        expect(controller.startAngle, 0);
        expect(controller.angle, 0);
      });
    });

    group('resume', () {
      test('behaves as start() when never started', () {
        controller.resume();
        expect(controller.isSpinning, isTrue);
        expect(controller.startAngle, 0);
        expect(controller.epoch, 1);
        expect(notifications, 1);
      });

      test('is a no-op while already spinning', () {
        controller.start();
        notifications = 0;

        controller.resume();
        expect(controller.epoch, 1);
        expect(notifications, 0);
      });

      test('continues from the current angle after stop()', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start();
        elapsed = 0.25;
        controller.stop();
        elapsed = 0;
        notifications = 0;

        controller.resume();
        expect(controller.isSpinning, isTrue);
        expect(controller.epoch, 2);
        expect(controller.angle, 90);
        expect(notifications, 1);
      });
    });

    group('stop', () {
      test('freezes the live angle and returns it', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start(angle: 90);
        elapsed = 0.25;
        notifications = 0;

        final stoppedAt = controller.stop();
        elapsed = 0.75;

        expect(stoppedAt, 180);
        expect(controller.isSpinning, isFalse);
        expect(controller.angle, 180);
        expect(notifications, 1);
      });

      test('returns the angle without notifying when already stopped', () {
        controller.reset(angle: 30);
        notifications = 0;

        expect(controller.stop(), 30);
        expect(notifications, 0);
      });
    });

    group('reset', () {
      test('stops at startAngle when no angle is given', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start(angle: 90);
        elapsed = 0.5;
        notifications = 0;

        controller.reset();
        expect(controller.isSpinning, isFalse);
        expect(controller.angle, 90);
        expect(notifications, 1);
      });

      test('stops at the given normalised angle', () {
        controller.start();
        notifications = 0;

        controller.reset(angle: 405);
        expect(controller.isSpinning, isFalse);
        expect(controller.angle, 45);
        expect(controller.startAngle, 0);
        expect(notifications, 1);
      });
    });

    group('attach and detach', () {
      test('asserts when attached twice', () {
        controller.attach(() => 0);
        expect(() => controller.attach(() => 0), throwsAssertionError);
      });

      test('detach rebases a spinning controller before releasing', () {
        var elapsed = 0.0;
        controller
          ..attach(() => elapsed)
          ..start();
        elapsed = 0.25;

        controller.detach();
        elapsed = 0.75;

        expect(controller.isSpinning, isTrue);
        expect(controller.epoch, 2);
        expect(controller.angle, 90);
      });

      test('detach does not rebase a stopped controller', () {
        controller
          ..attach(() => 0.5)
          ..detach();
        expect(controller.epoch, 0);
        expect(controller.angle, 0);
      });

      test('allows re-attaching after detach', () {
        controller
          ..attach(() => 0)
          ..detach();
        expect(() => controller.attach(() => 0), returnsNormally);
      });
    });
  });
}
