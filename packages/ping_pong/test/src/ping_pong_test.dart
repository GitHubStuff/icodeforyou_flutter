import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/arena_config.dart' show ArenaConfig;
import 'package:ping_pong/src/ball_spec.dart' show BallSpec;
import 'package:ping_pong/src/ball_too_large_error.dart' show BallTooLargeError;
import 'package:ping_pong/src/ping_pong.dart' show PingPong;
import 'package:ping_pong/src/ping_pong_ball.dart' show PingPongBall;
import 'package:ping_pong/src/ping_pong_controller.dart'
    show PingPongController;

import '../helpers/fake_random.dart';

/// Records every call the widget makes into the controller's seam.
class SpyController extends PingPongController {
  SpyController({super.random});

  final configs = <ArenaConfig>[];
  final deltas = <Duration>[];

  @override
  void configure(ArenaConfig config) {
    configs.add(config);
    super.configure(config);
  }

  @override
  void advance(Duration delta) {
    deltas.add(delta);
    super.advance(delta);
  }
}

const border = Color(0xFF000000);
const oneSecond = Duration(seconds: 1);
const halfSecond = Duration(milliseconds: 500);
const exitDuration = PingPongBall.defaultExitDuration;
const halfExit = Duration(milliseconds: 250);

/// Just past [exitDuration]: the animation reports completion only once
/// its elapsed time exceeds its duration.
const pastExit = Duration(milliseconds: 501);

const oneBall = [
  PingPongBall(radius: 10, border: border, child: SizedBox()),
];

const twoBalls = [
  PingPongBall(radius: 10, border: border, speed: 30, child: SizedBox()),
  PingPongBall(radius: 12, border: border, child: SizedBox()),
];

/// Two motionless balls, so recycling tests see stable positions.
const twoStillBalls = [
  PingPongBall(radius: 10, border: border, speed: 0, child: SizedBox()),
  PingPongBall(radius: 10, border: border, speed: 0, child: SizedBox()),
];

/// Two motionless balls that vanish the instant they are evicted.
const twoInstantBalls = [
  PingPongBall(
    radius: 10,
    border: border,
    speed: 0,
    exitDuration: Duration.zero,
    child: SizedBox(),
  ),
  PingPongBall(
    radius: 10,
    border: border,
    speed: 0,
    exitDuration: Duration.zero,
    child: SizedBox(),
  ),
];

const hugeBall = [
  PingPongBall(radius: 60, border: border, child: SizedBox()),
];

/// A controller that spawns one ball at (50, 50) moving right, and is
/// paused and disposed when the test ends. Pausing first stops the
/// widget's ticker before the notifier dies, mirroring what a real
/// caller must do.
SpyController spy([FakeRandom? random]) {
  final controller = SpyController(
    random: random ?? FakeRandom([0.5, 0.5, 0]),
  );
  addTearDown(() {
    controller
      ..pause()
      ..dispose();
  });
  return controller;
}

Widget harness({
  required PingPongController controller,
  List<PingPongBall> balls = oneBall,
  double width = 100,
  double height = 100,
  bool disableAnimations = false,
  HapticIntensity haptic = HapticIntensity.light,
  String emptyMessage = PingPong.defaultEmptyMessage,
  bool recycle = true,
  ValueChanged<int>? onSpawned,
  ValueChanged<int>? onEvicted,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: SizedBox(
        width: width,
        height: height,
        child: PingPong(
          controller: controller,
          pingpongBall: balls,
          speed: 50,
          haptic: haptic,
          emptyMessage: emptyMessage,
          recycle: recycle,
          onSpawned: onSpawned,
          onEvicted: onEvicted,
        ),
      ),
    ),
  ),
);

/// Pumps a recycling arena of [balls] to the frame in which ball 0 is
/// evicted. The exit animation exists after this but has not yet
/// ticked; pump once more before advancing the clock to drive it.
Future<SpyController> pumpToEviction(
  WidgetTester tester, {
  List<PingPongBall> balls = twoStillBalls,
}) async {
  // Every spawn attempt lands on (50, 50), so ball 1 always collides
  // with ball 0 and evicts it at the first spawn interval.
  final controller = spy(FakeRandom.constant(0.5));
  await tester.pumpWidget(harness(controller: controller, balls: balls));
  controller.start();
  await tester.pump();
  await tester.pump(oneSecond);
  return controller;
}

void main() {
  Offset arenaTopLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byType(PingPong));

  Offset ballTopLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byType(PingPongBall)) - arenaTopLeft(tester);

  /// The ball's centre in arena coordinates; unlike its top-left this
  /// is unaffected by the exit animation's scale.
  Offset ballCenter(WidgetTester tester) =>
      tester.getCenter(find.byType(PingPongBall)) - arenaTopLeft(tester);

  final exitAnimation = find.byType(TweenAnimationBuilder<double>);

  /// The x-axis scale of the evicted ball's [Transform]. `Transform.scale`
  /// leaves the z axis at 1, so `getMaxScaleOnAxis` would always read 1.
  double exitScale(WidgetTester tester) => tester
      .widget<Transform>(
        find.ancestor(
          of: find.byType(PingPongBall),
          matching: find.byType(Transform),
        ),
      )
      .transform
      .storage[0];

  group('construction', () {
    test('has the documented defaults', () {
      final widget = PingPong(controller: spy(), pingpongBall: oneBall);

      expect(widget.speed, PingPong.defaultSpeed);
      expect(widget.spawnInterval, PingPong.defaultSpawnInterval);
      expect(widget.retryCap, PingPong.defaultRetryCap);
      expect(widget.haptic, HapticIntensity.light);
      expect(widget.emptyMessage, PingPong.defaultEmptyMessage);
      expect(widget.recycle, isTrue);
      expect(widget.onSpawned, isNull);
      expect(widget.onEvicted, isNull);
      expect(PingPong.defaultSpeed, 120);
      expect(PingPong.defaultSpawnInterval, oneSecond);
      expect(PingPong.defaultRetryCap, 25);
      expect(PingPong.defaultEmptyMessage, 'No Ping Pong balls');
    });

    test('rejects a negative speed', () {
      expect(
        () => PingPong(controller: spy(), pingpongBall: oneBall, speed: -1),
        throwsAssertionError,
      );
    });

    test('rejects a zero retry cap', () {
      expect(
        () => PingPong(
          controller: spy(),
          pingpongBall: oneBall,
          retryCap: 0,
        ),
        throwsAssertionError,
      );
    });
  });

  group('empty list', () {
    testWidgets('shows the default message', (tester) async {
      await tester.pumpWidget(harness(controller: spy(), balls: []));

      expect(find.text(PingPong.defaultEmptyMessage), findsOneWidget);
    });

    testWidgets('shows a custom message', (tester) async {
      await tester.pumpWidget(
        harness(controller: spy(), balls: [], emptyMessage: 'Nope'),
      );

      expect(find.text('Nope'), findsOneWidget);
    });

    testWidgets('does not configure the controller', (tester) async {
      final controller = spy();

      await tester.pumpWidget(harness(controller: controller, balls: []));

      expect(controller.configs, isEmpty);
    });
  });

  group('configuration', () {
    testWidgets('configures from layout bounds and widget fields', (
      tester,
    ) async {
      final controller = spy();

      await tester.pumpWidget(
        harness(controller: controller, width: 300, height: 200),
      );

      expect(
        controller.configs.single,
        const ArenaConfig(
          bounds: Size(300, 200),
          specs: [BallSpec(radius: 10, speed: 50)],
          spawnInterval: PingPong.defaultSpawnInterval,
          retryCap: PingPong.defaultRetryCap,
          motionless: false,
          recycle: true,
        ),
      );
    });

    testWidgets('uses a ball speed override when present', (tester) async {
      final controller = spy();

      await tester.pumpWidget(
        harness(controller: controller, balls: twoBalls),
      );

      expect(
        controller.configs.single.specs,
        const [
          BallSpec(radius: 10, speed: 30),
          BallSpec(radius: 12, speed: 50),
        ],
      );
    });

    testWidgets('reads reduced motion from MediaQuery', (tester) async {
      final controller = spy();

      await tester.pumpWidget(
        harness(controller: controller, disableAnimations: true),
      );

      expect(controller.configs.single.motionless, isTrue);
    });

    testWidgets('passes recycle through', (tester) async {
      final controller = spy();

      await tester.pumpWidget(
        harness(controller: controller, recycle: false),
      );

      expect(controller.configs.single.recycle, isFalse);
    });

    testWidgets('does not reconfigure on an equal rebuild', (tester) async {
      final controller = spy();

      await tester.pumpWidget(harness(controller: controller));
      await tester.pumpWidget(harness(controller: controller));

      expect(controller.configs, hasLength(1));
    });

    testWidgets('reconfigures and restarts spawning on resize', (tester) async {
      // Constant 0.5 spawns at the centre moving left.
      final controller = spy(FakeRandom.constant(0.5));
      await tester.pumpWidget(harness(controller: controller));
      controller.start();
      await tester.pump();
      await tester.pump(halfSecond);
      expect(ballTopLeft(tester), const Offset(15, 40));

      await tester.pumpWidget(harness(controller: controller, width: 200));
      await tester.pump();

      expect(controller.configs, hasLength(2));
      expect(controller.configs.last.bounds, const Size(200, 100));
      expect(controller.balls, hasLength(1));
      expect(controller.balls.single.index, 0);
      expect(ballTopLeft(tester), const Offset(90, 40));
    });

    testWidgets('reconfigures when the ball list changes', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));

      await tester.pumpWidget(
        harness(controller: controller, balls: twoBalls),
      );

      expect(controller.configs, hasLength(2));
      expect(controller.configs.last.specs, hasLength(2));
    });

    testWidgets('reconfigures when reduced motion changes', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));

      await tester.pumpWidget(
        harness(controller: controller, disableAnimations: true),
      );

      expect(controller.configs, hasLength(2));
      expect(controller.configs.last.motionless, isTrue);
    });

    testWidgets('surfaces a BallTooLargeError at layout', (tester) async {
      final controller = spy();

      await tester.pumpWidget(
        harness(controller: controller, balls: hugeBall),
      );

      expect(tester.takeException(), isA<BallTooLargeError>());
      expect(controller.isConfigured, isFalse);
    });
  });

  group('ticking', () {
    testWidgets('does not advance until the controller starts', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));

      await tester.pump(oneSecond);

      expect(controller.deltas, isEmpty);
      expect(find.byType(PingPongBall), findsNothing);
    });

    testWidgets('spawns and positions a ball once started', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));
      controller.start();

      await tester.pump();

      expect(controller.deltas, [Duration.zero]);
      expect(find.byType(PingPongBall), findsOneWidget);
      expect(ballTopLeft(tester), const Offset(40, 40));
    });

    testWidgets('feeds frame deltas and moves the ball', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));
      controller.start();
      await tester.pump();

      await tester.pump(halfSecond);

      expect(controller.deltas, [Duration.zero, halfSecond]);
      expect(ballTopLeft(tester), const Offset(65, 40));
    });

    testWidgets('stops advancing when paused', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));
      controller.start();
      await tester.pump();
      await tester.pump(halfSecond);
      final before = controller.deltas.length;

      controller.pause();
      await tester.pump(halfSecond);

      expect(controller.deltas, hasLength(before));
    });

    testWidgets('resumes with a fresh delta after pause', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));
      controller.start();
      await tester.pump();
      await tester.pump(halfSecond);
      controller.pause();
      await tester.pump(oneSecond);

      controller.start();
      await tester.pump();

      expect(controller.deltas.last, Duration.zero);
    });

    testWidgets('starts ticking if the controller is already running', (
      tester,
    ) async {
      final controller = spy()..start();

      await tester.pumpWidget(harness(controller: controller));
      await tester.pump();

      expect(controller.deltas, isNotEmpty);
    });

    testWidgets('places balls statically under reduced motion', (tester) async {
      final controller = spy(FakeRandom([0.5, 0.5]));
      await tester.pumpWidget(
        harness(controller: controller, disableAnimations: true),
      );
      controller.start();
      await tester.pump();

      await tester.pump(oneSecond);

      expect(ballTopLeft(tester), const Offset(40, 40));
    });
  });

  group('recycling', () {
    testWidgets('reports spawns and evictions and swaps the widget', (
      tester,
    ) async {
      // Every spawn attempt lands on (50, 50), so ball 1 always collides
      // with ball 0 and evicts it; with the arena empty it then fits.
      final controller = spy(FakeRandom.constant(0.5));
      final spawned = <int>[];
      final evicted = <int>[];
      await tester.pumpWidget(
        harness(
          controller: controller,
          balls: twoStillBalls,
          onSpawned: spawned.add,
          onEvicted: evicted.add,
        ),
      );
      controller.start();
      await tester.pump();
      expect(spawned, [0]);
      expect(tester.widget(find.byType(PingPongBall)), same(twoStillBalls[0]));

      await tester.pump(oneSecond);
      expect(evicted, [0]);
      expect(controller.displayedCount, 0);
      // The evicted ball is still drawn while it shrinks away.
      expect(tester.widget(find.byType(PingPongBall)), same(twoStillBalls[0]));

      await tester.pump(halfSecond);
      await tester.pump(halfSecond);
      expect(spawned, [0, 1]);
      expect(find.byWidget(twoStillBalls[1]), findsOneWidget);
      expect(controller.balls.single.index, 1);
    });

    testWidgets('does not evict when recycle is off', (tester) async {
      final controller = spy(FakeRandom.constant(0.5));
      final evicted = <int>[];
      await tester.pumpWidget(
        harness(
          controller: controller,
          balls: twoStillBalls,
          recycle: false,
          onEvicted: evicted.add,
        ),
      );
      controller.start();
      await tester.pump();

      await tester.pump(oneSecond);
      await tester.pump(oneSecond);

      expect(evicted, isEmpty);
      expect(find.byType(PingPongBall), findsOneWidget);
    });

    testWidgets('runs without spawn or evict callbacks', (tester) async {
      final controller = await pumpToEviction(tester);

      expect(tester.takeException(), isNull);
      expect(controller.displayedCount, 0);
    });
  });

  group('eviction animation', () {
    testWidgets('shrinks the evicted ball about its centre and ignores '
        'pointers', (tester) async {
      await pumpToEviction(tester);
      expect(exitAnimation, findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(PingPongBall),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
      expect(ballCenter(tester), const Offset(50, 50));
      expect(exitScale(tester), 1);

      await tester.pump(); // Starts the exit animation's clock.
      await tester.pump(halfExit);

      final midway = exitScale(tester);
      expect(midway, greaterThan(0));
      expect(midway, lessThan(1));
      expect(ballCenter(tester), const Offset(50, 50));

      await tester.pump(halfExit);

      expect(exitScale(tester), lessThan(midway));
    });

    testWidgets('removes the ball once the exit animation ends', (
      tester,
    ) async {
      await pumpToEviction(tester);

      await tester.pump(); // Starts the exit animation's clock.
      await tester.pump(pastExit);

      expect(exitAnimation, findsNothing);
      expect(find.byType(PingPongBall), findsNothing);
    });

    testWidgets('removes a ball with a zero exit duration at once', (
      tester,
    ) async {
      await pumpToEviction(tester, balls: twoInstantBalls);

      expect(exitAnimation, findsNothing);
      expect(find.byType(PingPongBall), findsNothing);
    });

    testWidgets('drops a running exit animation on reconfigure', (
      tester,
    ) async {
      final controller = await pumpToEviction(tester);
      expect(exitAnimation, findsOneWidget);

      await tester.pumpWidget(
        harness(controller: controller, balls: twoStillBalls, width: 200),
      );
      await tester.pump();

      expect(controller.configs, hasLength(2));
      expect(exitAnimation, findsNothing);
      expect(controller.balls.single.index, 0);
      expect(find.byType(PingPongBall), findsOneWidget);
    });
  });

  group('haptics', () {
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            calls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('fires the configured haptic once per eviction', (
      tester,
    ) async {
      final controller = spy(FakeRandom.constant(0.5));
      final evicted = <int>[];
      await tester.pumpWidget(
        harness(
          controller: controller,
          balls: twoStillBalls,
          onEvicted: evicted.add,
        ),
      );
      controller.start();
      await tester.pump();
      expect(calls, isEmpty);

      await tester.pump(oneSecond);

      expect(evicted, [0]);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'HapticFeedback.vibrate');
      expect(calls.single.arguments, 'HapticFeedbackType.lightImpact');
    });

    testWidgets('fires nothing on eviction with HapticIntensity.none', (
      tester,
    ) async {
      final controller = spy(FakeRandom.constant(0.5));
      final evicted = <int>[];
      await tester.pumpWidget(
        harness(
          controller: controller,
          balls: twoStillBalls,
          haptic: HapticIntensity.none,
          onEvicted: evicted.add,
        ),
      );
      controller.start();
      await tester.pump();

      await tester.pump(oneSecond);

      expect(evicted, [0]);
      expect(calls, isEmpty);
    });

    testWidgets('fires nothing on a wall collision', (tester) async {
      // One ball at (50, 50) moving right reaches the wall within a
      // second and bounces; no eviction can occur with a single ball.
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));
      controller.start();
      await tester.pump();

      await tester.pump(oneSecond);
      await tester.pump(oneSecond);

      expect(calls, isEmpty);
    });

    testWidgets('fires nothing when recycle is off', (tester) async {
      final controller = spy(FakeRandom.constant(0.5));
      await tester.pumpWidget(
        harness(controller: controller, balls: twoStillBalls, recycle: false),
      );
      controller.start();
      await tester.pump();

      await tester.pump(oneSecond);
      await tester.pump(oneSecond);

      expect(calls, isEmpty);
    });
  });

  group('controller lifecycle', () {
    testWidgets('attaches every callback', (tester) async {
      final controller = spy();

      await tester.pumpWidget(harness(controller: controller));

      expect(controller.onSpawned, isNotNull);
      expect(controller.onEvicted, isNotNull);
    });

    testWidgets('swaps to a new controller', (tester) async {
      final original = spy();
      final replacement = spy();
      await tester.pumpWidget(harness(controller: original));
      replacement.start();

      await tester.pumpWidget(harness(controller: replacement));
      await tester.pump();

      expect(original.onSpawned, isNull);
      expect(original.onEvicted, isNull);
      expect(replacement.onSpawned, isNotNull);
      expect(replacement.onEvicted, isNotNull);
      expect(replacement.configs, hasLength(1));
      expect(replacement.deltas, isNotEmpty);
    });

    testWidgets('stops listening to a replaced controller', (tester) async {
      final original = spy();
      final replacement = spy();
      await tester.pumpWidget(harness(controller: original));
      await tester.pumpWidget(harness(controller: replacement));

      original.start();
      await tester.pump(halfSecond);

      expect(original.deltas, isEmpty);
    });

    testWidgets('detaches on dispose', (tester) async {
      final controller = spy();
      await tester.pumpWidget(harness(controller: controller));

      await tester.pumpWidget(const SizedBox());
      controller.start();
      await tester.pump(halfSecond);

      expect(controller.onSpawned, isNull);
      expect(controller.onEvicted, isNull);
      expect(controller.deltas, isEmpty);
    });
  });
}
