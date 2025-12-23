// observing_stateful_widget_test.dart
// Flutter 3.32.8 / Dart ">3.9.0"
import 'package:abstractions/abstractions.dart' show ExtendedStatefulWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test implementation for comprehensive coverage
class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends ExtendedStatefulWidget<TestWidget> {
  List<String> methodCalls = [];
  List<AppLifecycleState> lifecycleStates = [];
  List<double?> textScaleFactors = [];
  bool afterFirstLayoutCalled = false;
  bool platformBrightnessChanged = false;
  BuildContext? afterFirstLayoutContext;
  int metricsChanges = 0;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void initState() {
    methodCalls.add('initState');
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    methodCalls.add('didChangeAppLifecycleState');
    lifecycleStates.add(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeMetrics() {
    methodCalls.add('didChangeMetrics');
    metricsChanges++;
    super.didChangeMetrics();
  }

  @override
  void didChangePlatformBrightness() {
    methodCalls.add('didChangePlatformBrightness');
    platformBrightnessChanged = true;
    super.didChangePlatformBrightness();
  }

  @override
  void didChangeTextScaleFactor() {
    methodCalls.add('didChangeTextScaleFactor');
    super.didChangeTextScaleFactor();
  }

  @override
  void dispose() {
    methodCalls.add('dispose');
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    methodCalls.add('afterFirstLayout');
    afterFirstLayoutCalled = true;
    afterFirstLayoutContext = context;
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    methodCalls.add('reportTextScaleFactor');
    textScaleFactors.add(textScaleFactor);
  }

  // Helper to trigger observer methods manually for testing
  void triggerDidChangeMetrics() {
    didChangeMetrics();
  }

  void triggerDidChangePlatformBrightness() {
    didChangePlatformBrightness();
  }

  void triggerDidChangeAppLifecycleState(AppLifecycleState state) {
    didChangeAppLifecycleState(state);
  }
}

void main() {
  group('ExtenedStatefulWidget Comprehensive Tests', () {
    late TestWidget widget;
    late _TestWidgetState state;

    setUp(() {
      widget = const TestWidget();
    });

    group('Initialization Tests', () {
      testWidgets('initState() calls all required methods in correct order', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        expect(state.methodCalls, contains('initState'));
        expect(state.methodCalls, contains('reportTextScaleFactor'));

        final initIndex = state.methodCalls.indexOf('initState');
        final reportIndex = state.methodCalls.indexOf('reportTextScaleFactor');
        expect(reportIndex, greaterThan(initIndex));

        expect(state.textScaleFactors, isNotEmpty);
        expect(state.textScaleFactors.first, isA<double>());
      });

      testWidgets('afterFirstLayout() is called after widget is built', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        expect(state.afterFirstLayoutCalled, isTrue);
        expect(state.methodCalls, contains('afterFirstLayout'));
        expect(state.afterFirstLayoutContext, isNotNull);
        expect(state.afterFirstLayoutContext, isA<BuildContext>());
      });
    });

    group('Observer Method Tests', () {
      testWidgets('didChangeMetrics() can be triggered and tracked', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        final initialMetricsCount = state.metricsChanges;

        // Manually trigger to test the method
        state.triggerDidChangeMetrics();

        expect(state.metricsChanges, equals(initialMetricsCount + 1));
        expect(state.methodCalls, contains('didChangeMetrics'));
      });

      testWidgets(
        'didChangePlatformBrightness() can be triggered and tracked',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(home: widget));
          state = tester.state<_TestWidgetState>(find.byType(TestWidget));

          expect(state.platformBrightnessChanged, isFalse);

          state.triggerDidChangePlatformBrightness();

          expect(state.platformBrightnessChanged, isTrue);
          expect(state.methodCalls, contains('didChangePlatformBrightness'));
        },
      );

      testWidgets('didChangeAppLifecycleState() handles all lifecycle states', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        final states = [
          AppLifecycleState.resumed,
          AppLifecycleState.inactive,
          AppLifecycleState.paused,
          AppLifecycleState.detached,
          AppLifecycleState.hidden,
        ];

        for (final lifecycleState in states) {
          state.triggerDidChangeAppLifecycleState(lifecycleState);
        }

        expect(state.lifecycleStates, equals(states));
        expect(
          state.methodCalls
              .where((call) => call == 'didChangeAppLifecycleState')
              .length,
          equals(states.length),
        );
      });

      testWidgets(
        'didChangeTextScaleFactor() updates scale factor via platform dispatcher',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(home: widget));
          state = tester.state<_TestWidgetState>(find.byType(TestWidget));

          final initialCount = state.textScaleFactors.length;

          // Use platform dispatcher to trigger actual observer method
          tester.platformDispatcher.textScaleFactorTestValue = 1.5;
          await tester.pump();

          expect(state.textScaleFactors.length, greaterThan(initialCount));
          expect(state.methodCalls, contains('didChangeTextScaleFactor'));

          tester.platformDispatcher.clearAllTestValues();
          tester.view.reset();
        },
      );
    });

    group('Stress Tests', () {
      testWidgets('handles rapid multiple observer method calls', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        final initialCallCount = state.methodCalls.length;

        // Rapid fire multiple observer methods
        for (int i = 0; i < 10; i++) {
          state.triggerDidChangeMetrics();
          state.triggerDidChangePlatformBrightness();
          state.triggerDidChangeAppLifecycleState(AppLifecycleState.resumed);
        }

        expect(state.methodCalls.length, greaterThan(initialCallCount + 25));
        expect(state.metricsChanges, equals(10));
      });

      testWidgets('handles concurrent observer events', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        // Simulate concurrent events
        state.triggerDidChangeMetrics();
        state.triggerDidChangePlatformBrightness();
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        state.triggerDidChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.pump();

        expect(
          state.methodCalls,
          containsAll([
            'didChangeMetrics',
            'didChangePlatformBrightness',
            'didChangeTextScaleFactor',
            'didChangeAppLifecycleState',
          ]),
        );

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });

    group('Edge Case Tests', () {
      testWidgets('handles null text scale factor gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        state.textScaleFactors.clear();
        state.methodCalls.clear();

        state.reportTextScaleFactor(null);

        expect(state.textScaleFactors, contains(null));
        expect(state.methodCalls, contains('reportTextScaleFactor'));
      });

      testWidgets('afterFirstLayout receives valid BuildContext', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        expect(state.afterFirstLayoutContext, isNotNull);
        expect(state.afterFirstLayoutContext, isA<BuildContext>());

        expect(
          () => MediaQuery.of(state.afterFirstLayoutContext!),
          returnsNormally,
        );
      });

      testWidgets('reportTextScaleFactor handles extreme values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        final extremeValues = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0];

        for (final value in extremeValues) {
          state.reportTextScaleFactor(value);
        }

        expect(state.textScaleFactors, containsAll(extremeValues));
      });
    });

    group('Lifecycle and Cleanup Tests', () {
      testWidgets('dispose() removes observer and calls super', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        expect(state.mounted, isTrue);

        await tester.pumpWidget(const MaterialApp(home: Placeholder()));

        expect(state.methodCalls, contains('dispose'));
        expect(state.mounted, isFalse);
      });

      testWidgets('full widget lifecycle works correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        // Initialization
        expect(state.methodCalls, contains('initState'));
        expect(state.methodCalls, contains('reportTextScaleFactor'));
        expect(state.methodCalls, contains('afterFirstLayout'));

        // Trigger various observer methods
        state.triggerDidChangeMetrics();
        state.triggerDidChangePlatformBrightness();
        state.triggerDidChangeAppLifecycleState(AppLifecycleState.paused);

        // Disposal
        await tester.pumpWidget(const MaterialApp(home: Placeholder()));
        expect(state.methodCalls, contains('dispose'));
      });

      testWidgets('widget survives rebuild without issues', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        final initialCallCount = state.methodCalls.length;

        // Rebuild the same widget
        await tester.pumpWidget(MaterialApp(home: widget));

        // Should not create new state or duplicate calls
        expect(state.methodCalls.length, equals(initialCallCount));
        expect(state.mounted, isTrue);
      });
    });

    group('Platform Integration Tests', () {
      testWidgets('multiple platform changes work together', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: widget));
        state = tester.state<_TestWidgetState>(find.byType(TestWidget));

        // Multiple platform changes
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        await tester.pump();

        tester.platformDispatcher.textScaleFactorTestValue = 1.8;
        await tester.pump();

        // Should handle multiple changes
        expect(
          state.methodCalls
              .where((call) => call == 'didChangeTextScaleFactor')
              .length,
          greaterThanOrEqualTo(2),
        );

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });
  });
}
