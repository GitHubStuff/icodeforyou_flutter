// programs/widgetbook_workspace/lib/packages/custom_widgets/crash_screen/crash_screen.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show CrashScreen;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'
    show GoRoute, GoRouter, InheritedGoRouter, RoutingConfig;
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Initial error text shown in the error knob.
const String _kInitialError =
    'StateError: CrashScreenArgs was null in state.extra';

/// go_router location offered by the Resume button when enabled.
const String _kResumePath = '/home';

/// Deterministic sample stack trace for the stackTrace knob.
const String _kSampleStackTrace = '''
#0      ApplicationStartup.run (package:application_startup/src/application_startup.dart:42:7)
#1      main (package:black_velvet/main.dart:12:29)
#2      _runMain.<anonymous closure> (dart:ui/hooks.dart:301:23)
#3      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
#4      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:184:12)''';

@widgetbook.UseCase(name: 'Default', type: CrashScreen)
Widget buildCrashScreenUseCase(BuildContext context) {
  final error = context.knobs.string(
    label: 'error',
    initialValue: _kInitialError,
  );
  final includeStackTrace = context.knobs.boolean(
    label: 'stackTrace',
    initialValue: true,
    description: 'Off passes null, exercising the error-only layout.',
  );
  final offerResume = context.knobs.boolean(
    label: 'resumePath',
    initialValue: true,
    description:
        "On passes '$_kResumePath'; off passes null and hides "
        'the Resume button.',
  );
  final offerReport = context.knobs.boolean(
    label: 'onReport',
    initialValue: true,
    description: 'Off passes null and hides the Report button.',
  );

  return _CrashScreenUseCaseHarness(
    error: error,
    stackTrace: includeStackTrace
        ? StackTrace.fromString(_kSampleStackTrace)
        : null,
    resumePath: offerResume ? _kResumePath : null,
    onReport: offerReport ? () => showToast('onReport') : null,
  );
}

/// Router-providing harness for [CrashScreen].
///
/// The Resume button calls `context.go`, which resolves a [GoRouter]
/// through [InheritedGoRouter]. The harness owns a [_UseCaseGoRouter]
/// whose `go` reports through a toast instead of navigating, and
/// disposes it with the harness — a [GoRouter] is a `ChangeNotifier`
/// and must not be created per rebuild in the use case builder.
final class _CrashScreenUseCaseHarness extends StatefulWidget {
  const _CrashScreenUseCaseHarness({
    required this.error,
    required this.stackTrace,
    required this.resumePath,
    required this.onReport,
  });

  /// Forwarded to [CrashScreen.error].
  final Object error;

  /// Forwarded to [CrashScreen.stackTrace].
  final StackTrace? stackTrace;

  /// Forwarded to [CrashScreen.resumePath].
  final String? resumePath;

  /// Forwarded to [CrashScreen.onReport].
  final VoidCallback? onReport;

  @override
  State<_CrashScreenUseCaseHarness> createState() =>
      _CrashScreenUseCaseHarnessState();
}

class _CrashScreenUseCaseHarnessState
    extends State<_CrashScreenUseCaseHarness> {
  late final _UseCaseGoRouter _router = _UseCaseGoRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedGoRouter(
      goRouter: _router,
      child: CrashScreen(
        error: widget.error,
        stackTrace: widget.stackTrace,
        resumePath: widget.resumePath,
        onReport: widget.onReport,
      ),
    );
  }
}

/// A [GoRouter] whose [go] reports through a toast instead of routing.
///
/// [GoRouter]'s unnamed constructor is a factory, so the subclass
/// chains to the generative [GoRouter.routingConfig] instead, supplying
/// the single-route config through [_sharedRoutingConfig].
///
/// [CrashScreen] is the only screen in the workbench, so there is
/// nowhere to navigate; the toast confirms the exact location the
/// widget would have routed to in a real app.
final class _UseCaseGoRouter extends GoRouter {
  _UseCaseGoRouter() : super.routingConfig(routingConfig: _sharedRoutingConfig);

  /// Immutable single-route config shared by every harness mount.
  ///
  /// [GoRouter.routingConfig] takes a `ValueListenable` so live route
  /// tables can swap at runtime; the workbench never swaps, so one
  /// notifier lives for the session. Each router adds its listener on
  /// construction and removes it in `dispose`, so sharing is safe.
  static final ValueNotifier<RoutingConfig> _sharedRoutingConfig =
      ValueNotifier<RoutingConfig>(
        RoutingConfig(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
      );

  @override
  void go(String location, {Object? extra}) =>
      showToast("context.go('$location')");
}
