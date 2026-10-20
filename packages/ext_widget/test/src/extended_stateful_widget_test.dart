// packages/ext_widget/test/src/extended_stateful_widget_test.dart

import 'package:ext_widget/ext_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A subclass that overrides nothing, so every default hook body executes.
class _BareWidget extends StatefulWidget {
  const _BareWidget();

  @override
  State<_BareWidget> createState() => _BareState();
}

class _BareState extends ExtendedStatefulWidget<_BareWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// A subclass that overrides every hook and records what it received.
class _RecordingWidget extends StatefulWidget {
  const _RecordingWidget();

  @override
  State<_RecordingWidget> createState() => _RecordingState();
}

class _RecordingState extends ExtendedStatefulWidget<_RecordingWidget> {
  final List<AppLifecycleState> lifecycleStates = <AppLifecycleState>[];
  final List<double?> textScaleFactors = <double?>[];
  final List<BuildContext> firstLayoutContexts = <BuildContext>[];
  int metricsChanges = 0;
  int brightnessChanges = 0;

  @override
  void afterFirstLayout(BuildContext context) {
    firstLayoutContexts.add(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycleStates.add(state);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    metricsChanges++;
  }

  @override
  void didChangePlatformBrightness() {
    brightnessChanges++;
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    textScaleFactors.add(textScaleFactor);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

Future<void> _sendLifecycle(
  WidgetTester tester,
  AppLifecycleState state,
) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/lifecycle',
    const StringCodec().encodeMessage(state.toString()),
    (_) {},
  );
}

void main() {
  group('ExtendedStatefulWidget', () {
    group('initState', () {
      testWidgets('seeds reportTextScaleFactor with the platform value', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        await tester.pumpWidget(const _RecordingWidget());

        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );
        expect(state.textScaleFactors, <double?>[1.5]);
      });

      testWidgets('invokes afterFirstLayout exactly once with the context', (
        tester,
      ) async {
        await tester.pumpWidget(const _RecordingWidget());

        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );
        expect(state.firstLayoutContexts, hasLength(1));
        expect(state.firstLayoutContexts.single, same(state.context));

        await tester.pump();
        await tester.pump();

        expect(state.firstLayoutContexts, hasLength(1));
      });

      testWidgets('registers the state as a WidgetsBindingObserver', (
        tester,
      ) async {
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );

        await _sendLifecycle(tester, AppLifecycleState.paused);

        expect(state.lifecycleStates, contains(AppLifecycleState.paused));
      });
    });

    group('didChangeMetrics', () {
      testWidgets('is invoked when the view metrics change', (tester) async {
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );
        addTearDown(tester.view.resetPhysicalSize);

        tester.view.physicalSize = const Size(400, 800);
        await tester.pump();

        expect(state.metricsChanges, 1);
      });

      testWidgets('schedules a post-frame callback that completes without '
          'error', (tester) async {
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );

        state.didChangeMetrics();
        await tester.pump();

        expect(state.metricsChanges, 1);
        expect(tester.takeException(), isNull);
      });
    });

    group('didChangePlatformBrightness', () {
      testWidgets('is invoked when the platform brightness changes', (
        tester,
      ) async {
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pump();

        expect(state.brightnessChanges, 1);
      });
    });

    group('didChangeTextScaleFactor', () {
      testWidgets('forwards the new platform value to reportTextScaleFactor', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );

        tester.platformDispatcher.textScaleFactorTestValue = 2;
        await tester.pump();

        expect(state.textScaleFactors, <double?>[1, 2]);
      });

      testWidgets('reads the current platform value when called directly', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 3;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );

        state.didChangeTextScaleFactor();

        expect(state.textScaleFactors, <double?>[3, 3]);
      });
    });

    group('dispose', () {
      testWidgets('unregisters the observer so no further callbacks arrive', (
        tester,
      ) async {
        await tester.pumpWidget(const _RecordingWidget());
        final state = tester.state<_RecordingState>(
          find.byType(_RecordingWidget),
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await _sendLifecycle(tester, AppLifecycleState.paused);

        expect(state.lifecycleStates, isEmpty);
        expect(tester.takeException(), isNull);
      });
    });

    group('default hook implementations', () {
      testWidgets('are no-ops that neither throw nor require super', (
        tester,
      ) async {
        await tester.pumpWidget(const _BareWidget());
        final state = tester.state<_BareState>(find.byType(_BareWidget));

        state
          ..didChangeAppLifecycleState(AppLifecycleState.paused)
          ..didChangePlatformBrightness()
          ..afterFirstLayout(state.context)
          ..reportTextScaleFactor(null)
          ..reportTextScaleFactor(1.25);

        expect(tester.takeException(), isNull);
      });

      testWidgets('are exercised by the framework through initState', (
        tester,
      ) async {
        await tester.pumpWidget(const _BareWidget());
        await tester.pump();

        expect(find.byType(_BareWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
