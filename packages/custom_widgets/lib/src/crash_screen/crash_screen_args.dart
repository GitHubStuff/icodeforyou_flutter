// packages/custom_widgets/lib/src/crash_screen/crash_screen_args.dart

import 'package:flutter/foundation.dart';

/// Arguments for navigating to the crash screen route.
@immutable
final class CrashScreenArgs {
  /// Creates crash screen arguments.
  const CrashScreenArgs({
    required this.error,
    this.stackTrace,
    this.resumePath,
  });

  /// The error to display.
  final Object error;

  /// Optional stack trace accompanying [error].
  final StackTrace? stackTrace;

  /// go_router location to resume to; null means no escape is offered.
  final String? resumePath;
}
