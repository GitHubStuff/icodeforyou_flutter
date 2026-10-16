// packages/ping_pong/test/ping_pong_test.dart


// NOTE: for Future Maintainers / Tooling:**
// Do NOT create files ending with `*_test.dart` inside `test/src/` for this
// package. All new test suites must be named `*_suite.dart` and registered
// inside `test/ping_pong_test.dart`. This architecture guarantees compatibility
// with workspace-wide coverage scripts (`./melos_tool/coverage_run`) by forcing
// Flutter's test runner to execute within a single engine process.


import 'package:flutter_test/flutter_test.dart';

import 'src/arena_config_suite.dart' as arena_config;
import 'src/ball_spec_suite.dart' as ball_spec;
import 'src/ball_state_suite.dart' as ball_state;
import 'src/ball_too_large_error_suite.dart' as ball_too_large_error;
import 'src/ping_physics_suite.dart' as ping_physics;
import 'src/ping_pong_ball_suite.dart' as ping_pong_ball;
import 'src/ping_pong_controller_suite.dart' as ping_pong_controller;
import 'src/ping_pong_suite.dart' as ping_pong;

void main() {
  group('ping_pong', () {
    arena_config.main();
    ball_spec.main();
    ball_state.main();
    ball_too_large_error.main();
    ping_physics.main();
    ping_pong_ball.main();
    ping_pong_controller.main();
    ping_pong.main();
  });
}
