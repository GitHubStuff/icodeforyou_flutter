// packages/launch_splash_screen/lib/src/launch_task.dart

import 'dart:async' show Future;

/// A unit of launch work run by the splash screen.
///
/// A task is a *function* rather than a bare [Future] so that it starts
/// only when the splash starts, not when the widget tree is built or the
/// task list is assembled.
///
/// Tasks run concurrently and must be independent of one another: a task
/// may not rely on another task having completed. Any error thrown by a
/// task is reported through the splash screen's failure callback.
typedef LaunchTask = Future<void> Function();
