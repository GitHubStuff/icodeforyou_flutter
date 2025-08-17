// abstractions_part_two_test.dart
// Flutter 3.32.8 / Dart 3.8.1
// Advanced edge cases and scenarios not covered in main tests
import 'package:abstractions/abstractions.dart' show ObservingStatefulWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Error-throwing test widget to test exception handling
class ErrorThrowingWidget extends StatefulWidget {
  final bool throwInInit;
  final bool throwInObserver;
  final bool throwInDispose;
  final bool throwInAfterFirstLayout;

  const ErrorThrowingWidget({
    super.key,
    this.throwInInit = false,
    this.throwInObserver = false,
    this.throwInDispose = false,
    this.throwInAfterFirstLayout = false,
  });

  @override
  State<ErrorThrowingWidget> createState() => _ErrorThrowingWidgetState();
}

class _ErrorThrowingWidgetState
    extends ObservingStatefulWidget<ErrorThrowingWidget> {
  List<String> methodCalls = [];
  List<Exception> caughtExceptions = [];

  @override
  Widget build(BuildContext context) => const Placeholder();

  @override
  void initState() {
    methodCalls.add('initState');
    if (widget.throwInInit) {
      throw Exception('Test exception in initState');
    }
    super.initState();
  }

  @override
  void didChangeMetrics() {
    methodCalls.add('didChangeMetrics');
    if (widget.throwInObserver) {
      throw Exception('Test exception in observer');
    }
    super.didChangeMetrics();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    methodCalls.add('afterFirstLayout');
    if (widget.throwInAfterFirstLayout) {
      throw Exception('Test exception in afterFirstLayout');
    }
  }

  @override
  void dispose() {
    methodCalls.add('dispose');
    if (widget.throwInDispose) {
      throw Exception('Test exception in dispose');
    }
    super.dispose();
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    methodCalls.add('reportTextScaleFactor');
  }
}

// Multiple instance tracking widget
class InstanceTrackingWidget extends StatefulWidget {
  final String instanceId;

  // ignore: library_private_types_in_public_api
  static Map<String, _InstanceTrackingWidgetState> instances = {};
  static List<String> globalObserverCalls = [];

  const InstanceTrackingWidget({super.key, required this.instanceId});

  @override
  State<InstanceTrackingWidget> createState() => _InstanceTrackingWidgetState();

  static void clearGlobalState() {
    instances.clear();
    globalObserverCalls.clear();
  }
}

class _InstanceTrackingWidgetState
    extends ObservingStatefulWidget<InstanceTrackingWidget> {
  @override
  void initState() {
    InstanceTrackingWidget.instances[widget.instanceId] = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Text('Instance: ${widget.instanceId}');

  @override
  void didChangeMetrics() {
    InstanceTrackingWidget.globalObserverCalls.add(
      '${widget.instanceId}-didChangeMetrics',
    );
    super.didChangeMetrics();
  }

  @override
  void didChangeTextScaleFactor() {
    InstanceTrackingWidget.globalObserverCalls.add(
      '${widget.instanceId}-didChangeTextScaleFactor',
    );
    super.didChangeTextScaleFactor();
  }

  @override
  void dispose() {
    InstanceTrackingWidget.instances.remove(widget.instanceId);
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  void reportTextScaleFactor(double? textScaleFactor) {}
}

// Performance stress testing widget
class StressTestWidget extends StatefulWidget {
  const StressTestWidget({super.key});

  @override
  State<StressTestWidget> createState() => _StressTestWidgetState();
}

class _StressTestWidgetState extends ObservingStatefulWidget<StressTestWidget> {
  int observerCallCount = 0;
  List<DateTime> callTimestamps = [];
  Duration totalProcessingTime = Duration.zero;

  @override
  Widget build(BuildContext context) => const Placeholder();

  @override
  void didChangeMetrics() {
    final startTime = DateTime.now();
    observerCallCount++;
    callTimestamps.add(startTime);

    // Simulate some processing
    for (int i = 0; i < 1000; i++) {
      // Busy work
    }

    final endTime = DateTime.now();
    totalProcessingTime += endTime.difference(startTime);
    super.didChangeMetrics();
  }

  @override
  void didChangeTextScaleFactor() {
    observerCallCount++;
    callTimestamps.add(DateTime.now());
    super.didChangeTextScaleFactor();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  void reportTextScaleFactor(double? textScaleFactor) {}

  double get averageProcessingTimeMs {
    if (callTimestamps.isEmpty) return 0.0;
    return totalProcessingTime.inMicroseconds / callTimestamps.length / 1000.0;
  }
}

// Context validity testing widget
class ContextTestWidget extends StatefulWidget {
  const ContextTestWidget({super.key});

  @override
  State<ContextTestWidget> createState() => _ContextTestWidgetState();
}

class _ContextTestWidgetState
    extends ObservingStatefulWidget<ContextTestWidget> {
  BuildContext? storedContext;
  List<String> contextValidityResults = [];

  @override
  Widget build(BuildContext context) {
    storedContext = context;
    return const Placeholder();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Test context validity in afterFirstLayout
    try {
      MediaQuery.of(context);
      contextValidityResults.add('afterFirstLayout-valid');
    } catch (e) {
      contextValidityResults.add('afterFirstLayout-invalid');
    }

    // Test stored context
    try {
      if (storedContext != null) {
        MediaQuery.of(storedContext!);
        contextValidityResults.add('stored-valid');
      }
    } catch (e) {
      contextValidityResults.add('stored-invalid');
    }
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {}

  void testContextAfterDisposal() {
    try {
      if (storedContext != null) {
        MediaQuery.of(storedContext!);
        contextValidityResults.add('disposed-valid');
      }
    } catch (e) {
      contextValidityResults.add('disposed-invalid');
    }
  }
}

void main() {
  group('ObservingStatefulWidget Advanced Edge Cases', () {
    setUp(() {
      InstanceTrackingWidget.clearGlobalState();
    });

    group('Error Handling Tests', () {
      testWidgets('handles exceptions in initState gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: ErrorThrowingWidget(throwInInit: true)),
        );
        expect(tester.takeException(), isA<Exception>());
      });

      testWidgets('handles exceptions in observer methods', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: ErrorThrowingWidget(throwInObserver: true)),
        );

        final state = tester.state<_ErrorThrowingWidgetState>(
          find.byType(ErrorThrowingWidget),
        );

        // Should not crash when observer throws
        expect(() => state.didChangeMetrics(), throwsException);
        expect(state.methodCalls, contains('didChangeMetrics'));
      });

      testWidgets('handles exceptions in afterFirstLayout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: ErrorThrowingWidget(throwInAfterFirstLayout: true)),
        );
        expect(tester.takeException(), isA<Exception>());
      });

      testWidgets('handles exceptions in dispose', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ErrorThrowingWidget(throwInDispose: true)),
        );

        await tester.pumpWidget(MaterialApp(home: Placeholder()));
        expect(tester.takeException(), isA<Exception>());
      });
    });

    group('Multiple Instance Tests', () {
      testWidgets('multiple widget instances do not interfere', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                InstanceTrackingWidget(instanceId: 'widget1'),
                InstanceTrackingWidget(instanceId: 'widget2'),
                InstanceTrackingWidget(instanceId: 'widget3'),
              ],
            ),
          ),
        );

        expect(InstanceTrackingWidget.instances.length, equals(3));
        expect(
          InstanceTrackingWidget.instances.keys,
          containsAll(['widget1', 'widget2', 'widget3']),
        );

        // Trigger observer event
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        await tester.pump();

        // All instances should receive the observer call
        expect(InstanceTrackingWidget.globalObserverCalls.length, equals(3));
        expect(
          InstanceTrackingWidget.globalObserverCalls,
          containsAll([
            'widget1-didChangeTextScaleFactor',
            'widget2-didChangeTextScaleFactor',
            'widget3-didChangeTextScaleFactor',
          ]),
        );

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('partial disposal of multiple instances works correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                InstanceTrackingWidget(
                  key: ValueKey('widget1'),
                  instanceId: 'widget1',
                ),
                InstanceTrackingWidget(
                  key: ValueKey('widget2'),
                  instanceId: 'widget2',
                ),
              ],
            ),
          ),
        );

        expect(InstanceTrackingWidget.instances.length, equals(2));

        // Remove one widget by rebuilding with only one
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                InstanceTrackingWidget(
                  key: ValueKey('widget2'),
                  instanceId: 'widget2',
                ),
              ],
            ),
          ),
        );

        expect(InstanceTrackingWidget.instances.length, equals(1));
        expect(InstanceTrackingWidget.instances.keys, contains('widget2'));
      });
    });

    group('Performance and Stress Tests', () {
      testWidgets('handles rapid observer method calls efficiently', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: StressTestWidget()));

        final state = tester.state<_StressTestWidgetState>(
          find.byType(StressTestWidget),
        );

        final stopwatch = Stopwatch()..start();

        // Rapid fire observer calls
        for (int i = 0; i < 100; i++) {
          state.didChangeMetrics();
        }

        stopwatch.stop();

        expect(state.observerCallCount, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
        expect(
          state.averageProcessingTimeMs,
          lessThan(10.0),
        ); // Each call < 10ms
      });

      testWidgets('maintains performance under sustained load', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: StressTestWidget()));

        final state = tester.state<_StressTestWidgetState>(
          find.byType(StressTestWidget),
        );

        // Sustained load test
        for (int batch = 0; batch < 10; batch++) {
          for (int i = 0; i < 50; i++) {
            state.didChangeMetrics();
          }
          await tester.pump(); // Allow frame processing
        }

        expect(state.observerCallCount, equals(500));
        expect(
          state.averageProcessingTimeMs,
          lessThan(15.0),
        ); // Still reasonable
      });
    });

    group('Context Validity Tests', () {
      testWidgets('afterFirstLayout receives valid context', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: ContextTestWidget()));

        final state = tester.state<_ContextTestWidgetState>(
          find.byType(ContextTestWidget),
        );

        expect(
          state.contextValidityResults,
          contains('afterFirstLayout-valid'),
        );
        expect(state.contextValidityResults, contains('stored-valid'));
      });

      testWidgets('context becomes invalid after disposal', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: ContextTestWidget()));

        final state = tester.state<_ContextTestWidgetState>(
          find.byType(ContextTestWidget),
        );

        // Dispose the widget
        await tester.pumpWidget(const MaterialApp(home: Placeholder()));

        // Test context after disposal
        state.testContextAfterDisposal();
        expect(state.contextValidityResults, contains('disposed-invalid'));
      });
    });

    group('Hot Reload and Rebuild Tests', () {
      testWidgets('survives hot reload simulation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: InstanceTrackingWidget(instanceId: 'reload-test')),
        );

        expect(InstanceTrackingWidget.instances.length, equals(1));

        // Simulate hot reload by rebuilding with same widget
        await tester.pumpWidget(
          MaterialApp(home: InstanceTrackingWidget(instanceId: 'reload-test')),
        );

        // Should maintain single instance
        expect(InstanceTrackingWidget.instances.length, equals(1));
      });

      testWidgets('handles rapid mount/unmount cycles', (
        WidgetTester tester,
      ) async {
        for (int i = 0; i < 20; i++) {
          await tester.pumpWidget(
            MaterialApp(home: InstanceTrackingWidget(instanceId: 'cycle-$i')),
          );

          await tester.pumpWidget(const MaterialApp(home: Placeholder()));
        }

        // All instances should be cleaned up
        expect(InstanceTrackingWidget.instances.length, equals(0));
      });
    });

    group('Platform Edge Cases', () {
      testWidgets('handles extreme text scale factor values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: InstanceTrackingWidget(instanceId: 'extreme')),
        );

        final extremeValues = [0.01, 0.1, 10.0, 100.0, 1000.0];

        for (final value in extremeValues) {
          InstanceTrackingWidget.globalObserverCalls.clear();

          tester.platformDispatcher.textScaleFactorTestValue = value;
          await tester.pump();

          expect(
            InstanceTrackingWidget.globalObserverCalls,
            contains('extreme-didChangeTextScaleFactor'),
          );
        }

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('handles rapid platform changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: InstanceTrackingWidget(instanceId: 'rapid')),
        );

        // Rapid platform changes
        for (int i = 0; i < 50; i++) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.0 + (i * 0.1);
          await tester.pump();
        }

        // Should handle all changes without crashing
        expect(InstanceTrackingWidget.globalObserverCalls.length, equals(50));

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });

    group('Memory and Resource Tests', () {
      testWidgets('does not leak observers with rapid widget creation', (
        WidgetTester tester,
      ) async {
        // Create and destroy many widgets rapidly
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: InstanceTrackingWidget(instanceId: 'leak-test-$i'),
            ),
          );
          await tester.pumpAndSettle();

          // Destroy the widget
          await tester.pumpWidget(MaterialApp(home: Placeholder()));
          await tester.pumpAndSettle();
        }

        // All instances should be cleaned up
        expect(InstanceTrackingWidget.instances.length, equals(0));
      });

      testWidgets('handles widget tree rebuilds efficiently', (
        WidgetTester tester,
      ) async {
        for (int i = 0; i < 20; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Column(
                key: ValueKey(i),
                children: List.generate(
                  5,
                  (index) =>
                      InstanceTrackingWidget(instanceId: 'rebuild-$i-$index'),
                ),
              ),
            ),
          );
        }

        // Should have 5 instances from the last rebuild
        expect(InstanceTrackingWidget.instances.length, equals(5));
      });
    });

    group('Integration Tests', () {
      testWidgets('works correctly in complex widget tree', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: InstanceTrackingWidget(instanceId: 'appbar'),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        InstanceTrackingWidget(instanceId: 'list-1'),
                        InstanceTrackingWidget(instanceId: 'list-2'),
                      ],
                    ),
                  ),
                  InstanceTrackingWidget(instanceId: 'footer'),
                ],
              ),
            ),
          ),
        );

        expect(InstanceTrackingWidget.instances.length, equals(4));

        // Trigger observer event
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        await tester.pump();

        // All instances should receive the event
        expect(InstanceTrackingWidget.globalObserverCalls.length, equals(4));

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });
  });
}
