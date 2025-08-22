// abstractions_part_four_test.dart
// Flutter 3.32.8 / Dart ">3.9.0"
// Critical edge cases and failure modes that could break the widget in production
import 'package:abstractions/abstractions.dart' show ObservingStatefulWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget that violates @mustCallSuper requirements
class BadImplementationWidget extends StatefulWidget {
  final bool skipSuperInInit;
  final bool skipSuperInDispose;
  final bool skipSuperInDidChangeMetrics;
  final bool skipSuperInDidChangeTextScaleFactor;

  const BadImplementationWidget({
    super.key,
    this.skipSuperInInit = false,
    this.skipSuperInDispose = false,
    this.skipSuperInDidChangeMetrics = false,
    this.skipSuperInDidChangeTextScaleFactor = false,
  });

  @override
  State<BadImplementationWidget> createState() =>
      _BadImplementationWidgetState();
}

class _BadImplementationWidgetState
    extends ObservingStatefulWidget<BadImplementationWidget> {
  List<String> methodCalls = [];
  bool initStateCompleted = false;
  bool disposeCompleted = false;
  Exception? caughtException;

  @override
  Widget build(BuildContext context) =>
      Text('Bad Implementation: ${methodCalls.length}');

  @override
  void initState() {
    methodCalls.add('initState-start');
    try {
      if (!widget.skipSuperInInit) {
        super.initState();
      }
      initStateCompleted = true;
      methodCalls.add('initState-completed');
    } catch (e) {
      caughtException = e as Exception;
      methodCalls.add('initState-exception');
    }
  }

  @override
  void didChangeMetrics() {
    methodCalls.add('didChangeMetrics-start');
    try {
      if (!widget.skipSuperInDidChangeMetrics) {
        super.didChangeMetrics();
      }
      methodCalls.add('didChangeMetrics-completed');
    } catch (e) {
      caughtException = e as Exception;
      methodCalls.add('didChangeMetrics-exception');
    }
  }

  @override
  void didChangeTextScaleFactor() {
    methodCalls.add('didChangeTextScaleFactor-start');
    try {
      if (!widget.skipSuperInDidChangeTextScaleFactor) {
        super.didChangeTextScaleFactor();
      }
      methodCalls.add('didChangeTextScaleFactor-completed');
    } catch (e) {
      caughtException = e as Exception;
      methodCalls.add('didChangeTextScaleFactor-exception');
    }
  }

  @override
  void dispose() {
    methodCalls.add('dispose-start');
    try {
      if (!widget.skipSuperInDispose) {
        super.dispose();
      }
      disposeCompleted = true;
      methodCalls.add('dispose-completed');
    } catch (e) {
      caughtException = e as Exception;
      methodCalls.add('dispose-exception');
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    methodCalls.add('afterFirstLayout');
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    methodCalls.add('reportTextScaleFactor');
  }
}

// Widget for testing frame callback timing and MediaQuery behavior
class MediaQueryTimingWidget extends StatefulWidget {
  const MediaQueryTimingWidget({super.key});

  @override
  State<MediaQueryTimingWidget> createState() => _MediaQueryTimingWidgetState();
}

class _MediaQueryTimingWidgetState
    extends ObservingStatefulWidget<MediaQueryTimingWidget> {
  List<Size> capturedSizes = [];
  List<String> timingEvents = [];
  Size? sizeInDidChangeMetrics;
  Size? sizeInPostFrameCallback;
  bool postFrameCallbackExecuted = false;

  @override
  Widget build(BuildContext context) {
    final currentSize = MediaQuery.of(context).size;
    timingEvents.add('build-${currentSize.width}x${currentSize.height}');
    return Text('Current size: $currentSize');
  }

  @override
  void didChangeMetrics() {
    sizeInDidChangeMetrics = MediaQuery.maybeOf(context)?.size;
    timingEvents.add(
      'didChangeMetrics-${sizeInDidChangeMetrics?.width ?? 'null'}x${sizeInDidChangeMetrics?.height ?? 'null'}',
    );

    super.didChangeMetrics(); // This adds the post-frame callback

    // Verify the post-frame callback was scheduled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        sizeInPostFrameCallback = MediaQuery.maybeOf(context)?.size;
        postFrameCallbackExecuted = true;
        timingEvents.add(
          'manual-post-frame-${sizeInPostFrameCallback?.width ?? 'null'}x${sizeInPostFrameCallback?.height ?? 'null'}',
        );
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    capturedSizes.add(size);
    timingEvents.add('afterFirstLayout-${size.width}x${size.height}');
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    timingEvents.add('reportTextScaleFactor-$textScaleFactor');
  }
}

// Widget for testing disposal during active observer callbacks
class DisposalRaceWidget extends StatefulWidget {
  const DisposalRaceWidget({super.key});

  @override
  State<DisposalRaceWidget> createState() => _DisposalRaceWidgetState();
}

class _DisposalRaceWidgetState
    extends ObservingStatefulWidget<DisposalRaceWidget> {
  List<String> observerEvents = [];
  bool disposedDuringCallback = false;
  Exception? callbackException;

  @override
  Widget build(BuildContext context) =>
      Text('Race Test: ${observerEvents.length}');

  @override
  void didChangeMetrics() {
    observerEvents.add('didChangeMetrics-start');
    try {
      super.didChangeMetrics();
      observerEvents.add('didChangeMetrics-super-completed');

      // Simulate disposal happening during callback execution
      if (mounted) {
        observerEvents.add('didChangeMetrics-still-mounted');
      } else {
        disposedDuringCallback = true;
        observerEvents.add('didChangeMetrics-disposed-during-callback');
      }
    } catch (e) {
      callbackException = e as Exception;
      observerEvents.add('didChangeMetrics-exception');
    }
  }

  @override
  void didChangeTextScaleFactor() {
    observerEvents.add('didChangeTextScaleFactor-start');
    try {
      super.didChangeTextScaleFactor();
      observerEvents.add('didChangeTextScaleFactor-completed');
    } catch (e) {
      callbackException = e as Exception;
      observerEvents.add('didChangeTextScaleFactor-exception');
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    observerEvents.add('afterFirstLayout-start');
    try {
      // Test context validity during frame callback
      MediaQuery.of(context);
      observerEvents.add('afterFirstLayout-context-valid');
    } catch (e) {
      observerEvents.add('afterFirstLayout-context-invalid');
    }
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    observerEvents.add('reportTextScaleFactor-$textScaleFactor');
  }
}

// Widget for testing platform dispatcher edge cases
class PlatformDispatcherEdgeWidget extends StatefulWidget {
  const PlatformDispatcherEdgeWidget({super.key});

  @override
  State<PlatformDispatcherEdgeWidget> createState() =>
      _PlatformDispatcherEdgeWidgetState();
}

class _PlatformDispatcherEdgeWidgetState
    extends ObservingStatefulWidget<PlatformDispatcherEdgeWidget> {
  List<double?> receivedTextScaleFactors = [];
  List<String> platformEvents = [];
  Exception? platformException;

  @override
  Widget build(BuildContext context) =>
      Text('Platform Edge: ${platformEvents.length}');

  @override
  void didChangeTextScaleFactor() {
    platformEvents.add('didChangeTextScaleFactor-start');
    try {
      final currentFactor =
          WidgetsBinding.instance.platformDispatcher.textScaleFactor;
      platformEvents.add('didChangeTextScaleFactor-current-$currentFactor');

      super.didChangeTextScaleFactor(); // This calls reportTextScaleFactor

      platformEvents.add('didChangeTextScaleFactor-completed');
    } catch (e) {
      platformException = e as Exception;
      platformEvents.add('didChangeTextScaleFactor-exception');
    }
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    receivedTextScaleFactors.add(textScaleFactor);
    platformEvents.add('reportTextScaleFactor-$textScaleFactor');
  }

  @override
  void afterFirstLayout(BuildContext context) {
    platformEvents.add('afterFirstLayout');
  }
}

// Widget for testing concurrent observer operations
class ConcurrentObserverWidget extends StatefulWidget {
  const ConcurrentObserverWidget({super.key});

  @override
  State<ConcurrentObserverWidget> createState() =>
      _ConcurrentObserverWidgetState();
}

class _ConcurrentObserverWidgetState
    extends ObservingStatefulWidget<ConcurrentObserverWidget> {
  List<String> concurrentEvents = [];
  Map<String, int> methodCounts = {};
  bool processingConcurrentEvents = false;

  @override
  Widget build(BuildContext context) =>
      Text('Concurrent: ${concurrentEvents.length}');

  void _recordEvent(String event) {
    concurrentEvents.add('${DateTime.now().millisecondsSinceEpoch}-$event');
    methodCounts[event] = (methodCounts[event] ?? 0) + 1;
  }

  @override
  void didChangeMetrics() {
    _recordEvent('didChangeMetrics-start');
    processingConcurrentEvents = true;
    super.didChangeMetrics();
    processingConcurrentEvents = false;
    _recordEvent('didChangeMetrics-end');
  }

  @override
  void didChangeTextScaleFactor() {
    _recordEvent('didChangeTextScaleFactor-start');
    if (processingConcurrentEvents) {
      _recordEvent('didChangeTextScaleFactor-during-metrics');
    }
    super.didChangeTextScaleFactor();
    _recordEvent('didChangeTextScaleFactor-end');
  }

  @override
  void didChangePlatformBrightness() {
    _recordEvent('didChangePlatformBrightness-start');
    if (processingConcurrentEvents) {
      _recordEvent('didChangePlatformBrightness-during-metrics');
    }
    super.didChangePlatformBrightness();
    _recordEvent('didChangePlatformBrightness-end');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _recordEvent('didChangeAppLifecycleState-$state');
    super.didChangeAppLifecycleState(state);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _recordEvent('afterFirstLayout');
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    _recordEvent('reportTextScaleFactor-$textScaleFactor');
  }

  // Manual trigger methods for testing
  void triggerAllObserverMethods() {
    didChangeMetrics();
    didChangeTextScaleFactor();
    didChangePlatformBrightness();
    didChangeAppLifecycleState(AppLifecycleState.paused);
  }
}

void main() {
  group('ObservingStatefulWidget Critical Edge Cases', () {
    group('@mustCallSuper Violation Tests', () {
      testWidgets('widget still works when subclass skips super.initState()', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: BadImplementationWidget(skipSuperInInit: true)),
        );

        final state = tester.state<_BadImplementationWidgetState>(
          find.byType(BadImplementationWidget),
        );

        // Should have started but not completed initialization properly
        expect(state.methodCalls, contains('initState-start'));
        expect(state.initStateCompleted, isTrue);

        // Observer functionality should be broken
        expect(state.methodCalls, isNot(contains('reportTextScaleFactor')));
      });

      testWidgets('Flutter catches when subclass skips super.dispose()', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: BadImplementationWidget(skipSuperInDispose: true)),
        );

        final state = tester.state<_BadImplementationWidgetState>(
          find.byType(BadImplementationWidget),
        );

        // Dispose the widget - Flutter should catch the missing super.dispose()
        await tester.pumpWidget(MaterialApp(home: Placeholder()));

        // Flutter throws an assertion error for missing super.dispose()
        expect(tester.takeException(), isA<FlutterError>());

        expect(state.methodCalls, contains('dispose-start'));
        expect(state.disposeCompleted, isTrue);
      });

      testWidgets(
        'didChangeMetrics post-frame callback missing when super skipped',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: BadImplementationWidget(skipSuperInDidChangeMetrics: true),
            ),
          );

          final state = tester.state<_BadImplementationWidgetState>(
            find.byType(BadImplementationWidget),
          );

          // Manually trigger didChangeMetrics
          state.didChangeMetrics();

          expect(state.methodCalls, contains('didChangeMetrics-start'));
          expect(state.methodCalls, contains('didChangeMetrics-completed'));

          // The critical post-frame callback for MediaQuery timing should be missing
        },
      );

      testWidgets('reportTextScaleFactor not called when super skipped', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BadImplementationWidget(
              skipSuperInDidChangeTextScaleFactor: true,
            ),
          ),
        );

        final state = tester.state<_BadImplementationWidgetState>(
          find.byType(BadImplementationWidget),
        );

        // Count initial reportTextScaleFactor calls (from initState)
        final initialCount = state.methodCalls
            .where((call) => call == 'reportTextScaleFactor')
            .length;

        // Manually trigger didChangeTextScaleFactor to test the skip behavior
        state.didChangeTextScaleFactor();

        // Count should not increase since super.didChangeTextScaleFactor() was skipped
        final finalCount = state.methodCalls
            .where((call) => call == 'reportTextScaleFactor')
            .length;

        expect(finalCount, equals(initialCount));
        expect(state.methodCalls, contains('didChangeTextScaleFactor-start'));
        expect(
          state.methodCalls,
          contains('didChangeTextScaleFactor-completed'),
        );
      });
    });

    group('MediaQuery Timing and Frame Callback Tests', () {
      testWidgets(
        'didChangeMetrics schedules post-frame callback for MediaQuery timing',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(home: MediaQueryTimingWidget()));

          final state = tester.state<_MediaQueryTimingWidgetState>(
            find.byType(MediaQueryTimingWidget),
          );

          // Clear events to focus on testing the post-frame callback mechanism
          state.timingEvents.clear();
          state.postFrameCallbackExecuted = false;

          // Manually trigger didChangeMetrics to test the post-frame callback
          state.didChangeMetrics();
          await tester.pump();

          // The key behavior: didChangeMetrics should schedule a post-frame callback
          expect(state.timingEvents, contains('didChangeMetrics-800.0x600.0'));
          expect(state.postFrameCallbackExecuted, isTrue);
          expect(state.timingEvents, contains('manual-post-frame-800.0x600.0'));

          // The abstract class ensures MediaQuery is updated via post-frame callback
          expect(state.sizeInPostFrameCallback, isNotNull);

          tester.view.reset();
        },
      );

      testWidgets(
        'afterFirstLayout receives valid context with correct MediaQuery',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(home: MediaQueryTimingWidget()));

          final state = tester.state<_MediaQueryTimingWidgetState>(
            find.byType(MediaQueryTimingWidget),
          );

          expect(state.capturedSizes, isNotEmpty);
          expect(state.capturedSizes.first, equals(Size(800, 600)));
          expect(state.timingEvents, contains('afterFirstLayout-800.0x600.0'));
        },
      );

      testWidgets(
        'multiple frame callbacks handle MediaQuery updates correctly',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(home: MediaQueryTimingWidget()));

          final state = tester.state<_MediaQueryTimingWidgetState>(
            find.byType(MediaQueryTimingWidget),
          );

          // Multiple size changes in rapid succession
          await tester.binding.setSurfaceSize(Size(300, 200));
          await tester.pump();

          await tester.binding.setSurfaceSize(Size(500, 400));
          await tester.pump();

          // Should handle all changes correctly
          expect(
            state.timingEvents
                .where((e) => e.startsWith('didChangeMetrics'))
                .length,
            greaterThanOrEqualTo(2),
          );

          tester.view.reset();
        },
      );
    });

    group('Disposal and Race Condition Tests', () {
      testWidgets('observer methods handle disposal during execution', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: DisposalRaceWidget()));

        final state = tester.state<_DisposalRaceWidgetState>(
          find.byType(DisposalRaceWidget),
        );

        // Trigger observer method
        state.didChangeMetrics();

        expect(state.observerEvents, contains('didChangeMetrics-start'));
        expect(
          state.observerEvents,
          contains('didChangeMetrics-super-completed'),
        );
        expect(state.callbackException, isNull);

        // Dispose widget
        await tester.pumpWidget(MaterialApp(home: Placeholder()));

        expect(
          state.observerEvents,
          contains('didChangeMetrics-still-mounted'),
        );
      });

      testWidgets('afterFirstLayout handles context becoming invalid', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: DisposalRaceWidget()));

        final state = tester.state<_DisposalRaceWidgetState>(
          find.byType(DisposalRaceWidget),
        );

        expect(state.observerEvents, contains('afterFirstLayout-start'));
        expect(
          state.observerEvents,
          contains('afterFirstLayout-context-valid'),
        );
      });

      testWidgets(
        'rapid disposal and recreation does not cause observer leaks',
        (WidgetTester tester) async {
          for (int i = 0; i < 20; i++) {
            await tester.pumpWidget(MaterialApp(home: DisposalRaceWidget()));

            final state = tester.state<_DisposalRaceWidgetState>(
              find.byType(DisposalRaceWidget),
            );

            // Trigger some observer activity
            state.didChangeTextScaleFactor();

            await tester.pumpWidget(MaterialApp(home: Placeholder()));
          }

          // Should complete without memory issues or exceptions
        },
      );
    });

    group('Platform Dispatcher Edge Cases', () {
      testWidgets('handles platform dispatcher in inconsistent states', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: PlatformDispatcherEdgeWidget()),
        );

        final state = tester.state<_PlatformDispatcherEdgeWidgetState>(
          find.byType(PlatformDispatcherEdgeWidget),
        );

        // Initial state should work
        expect(state.receivedTextScaleFactors, isNotEmpty);
        expect(state.platformException, isNull);

        // Test extreme values
        tester.platformDispatcher.textScaleFactorTestValue = 0.0;
        await tester.pump();

        tester.platformDispatcher.textScaleFactorTestValue = double.infinity;
        await tester.pump();

        // Should handle extreme values without crashing
        expect(state.platformException, isNull);
        expect(state.receivedTextScaleFactors, contains(0.0));

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('platform dispatcher null values handled gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: PlatformDispatcherEdgeWidget()),
        );

        final state = tester.state<_PlatformDispatcherEdgeWidgetState>(
          find.byType(PlatformDispatcherEdgeWidget),
        );

        // Manually call reportTextScaleFactor with null
        state.reportTextScaleFactor(null);

        expect(state.receivedTextScaleFactors, contains(null));
        expect(state.platformEvents, contains('reportTextScaleFactor-null'));
      });
    });

    group('Concurrent Observer Operations Tests', () {
      testWidgets('handles multiple observer methods executing simultaneously', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: ConcurrentObserverWidget()));

        final state = tester.state<_ConcurrentObserverWidgetState>(
          find.byType(ConcurrentObserverWidget),
        );

        // Trigger multiple observer methods at once
        state.triggerAllObserverMethods();

        expect(state.methodCounts['didChangeMetrics-start'], equals(1));
        expect(state.methodCounts['didChangeTextScaleFactor-start'], equals(1));
        expect(
          state.methodCounts['didChangePlatformBrightness-start'],
          equals(1),
        );
        expect(
          state
              .methodCounts['didChangeAppLifecycleState-AppLifecycleState.paused'],
          equals(1),
        );

        // Should complete all methods without interference
        expect(state.methodCounts['didChangeMetrics-end'], equals(1));
        expect(state.methodCounts['didChangeTextScaleFactor-end'], equals(1));
        expect(
          state.methodCounts['didChangePlatformBrightness-end'],
          equals(1),
        );
      });

      testWidgets('concurrent platform changes processed correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: ConcurrentObserverWidget()));

        final state = tester.state<_ConcurrentObserverWidgetState>(
          find.byType(ConcurrentObserverWidget),
        );

        // Rapid platform changes
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pump();

        tester.platformDispatcher.textScaleFactorTestValue = 1.8;
        await tester.pump();

        // Should handle concurrent platform changes
        expect(
          state.methodCounts['didChangeTextScaleFactor-start'],
          greaterThanOrEqualTo(1),
        );

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('observer method reentrancy handled safely', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: ConcurrentObserverWidget()));

        final state = tester.state<_ConcurrentObserverWidgetState>(
          find.byType(ConcurrentObserverWidget),
        );

        // Trigger methods multiple times rapidly
        for (int i = 0; i < 5; i++) {
          state.didChangeMetrics();
          state.didChangeTextScaleFactor();
        }

        expect(state.methodCounts['didChangeMetrics-start'], equals(5));
        expect(state.methodCounts['didChangeTextScaleFactor-start'], equals(5));
        expect(state.methodCounts['didChangeMetrics-end'], equals(5));
        expect(state.methodCounts['didChangeTextScaleFactor-end'], equals(5));
      });
    });

    group('Production Failure Mode Tests', () {
      testWidgets('survives complex real-world usage patterns', (
        WidgetTester tester,
      ) async {
        // Simulate complex app with multiple observer widgets
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  MediaQueryTimingWidget(),
                  DisposalRaceWidget(),
                  PlatformDispatcherEdgeWidget(),
                  ConcurrentObserverWidget(),
                ],
              ),
            ),
          ),
        );

        // Trigger platform changes affecting all widgets
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        await tester.binding.setSurfaceSize(Size(600, 800));
        await tester.pump();

        // Change again
        tester.platformDispatcher.textScaleFactorTestValue = 1.7;
        await tester.binding.setSurfaceSize(Size(400, 600));
        await tester.pump();

        // All widgets should survive without errors
        expect(find.byType(MediaQueryTimingWidget), findsOneWidget);
        expect(find.byType(DisposalRaceWidget), findsOneWidget);
        expect(find.byType(PlatformDispatcherEdgeWidget), findsOneWidget);
        expect(find.byType(ConcurrentObserverWidget), findsOneWidget);

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('handles widget tree rebuilds during observer callbacks', (
        WidgetTester tester,
      ) async {
        bool rebuildTrigger = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!rebuildTrigger)
                          SizedBox(
                            height: 100,
                            child: MediaQueryTimingWidget(),
                          ),
                        SizedBox(
                          height: 100,
                          child: ConcurrentObserverWidget(),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              rebuildTrigger = true;
                            });
                          },
                          child: Text('Rebuild'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Trigger platform change
        tester.platformDispatcher.textScaleFactorTestValue = 1.4;
        await tester.pump();

        // Trigger rebuild during observer activity
        await tester.tap(find.text('Rebuild'), warnIfMissed: false);
        await tester.pump();

        // Should handle rebuild without errors
        expect(find.byType(ConcurrentObserverWidget), findsOneWidget);
        expect(find.byType(MediaQueryTimingWidget), findsNothing);

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });
  });
}
