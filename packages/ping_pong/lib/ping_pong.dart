// packages/ping_pong/lib/ping_pong.dart
/// A widget that bounces circular balls around its own bounds.
///
/// Usage:
///
/// ```dart
/// final controller = PingPongController();
///
/// PingPong(
///   controller: controller,
///   pingpongBall: [
///     PingPongBall(
///       radius: 24,
///       border: Colors.black,
///       child: const FlutterLogo(),
///     ),
///   ],
///   onEvicted: (index) => debugPrint('ball $index made room'),
/// );
///
/// controller.start();
/// ```
///
/// A [BallTooLargeError] is thrown at the first layout if any ball
/// could never fit inside the widget.
library;

export 'example/ping_pong_example.dart' show PingPongExample;
export 'src/ball_too_large_error.dart' show BallTooLargeError;
export 'src/ping_pong.dart' show PingPong;
export 'src/ping_pong_ball.dart' show PingPongBall;
export 'src/ping_pong_controller.dart' show PingPongController;
