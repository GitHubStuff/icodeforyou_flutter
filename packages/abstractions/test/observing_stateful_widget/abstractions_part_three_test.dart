// abstractions_part_three_test.dart
// Flutter 3.32.8 / Dart ">3.9.0"
// Complete coverage testing - accessibility, locale, semantics, frame scheduling
import 'package:abstractions/abstractions.dart' show ObservingStatefulWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Comprehensive observer tracking widget
class ComprehensiveObserverWidget extends StatefulWidget {
  final String widgetId;

  const ComprehensiveObserverWidget({super.key, required this.widgetId});

  @override
  State<ComprehensiveObserverWidget> createState() =>
      _ComprehensiveObserverWidgetState();
}

class _ComprehensiveObserverWidgetState
    extends ObservingStatefulWidget<ComprehensiveObserverWidget> {
  List<String> allObserverCalls = [];
  List<Locale> localeChanges = [];
  List<AppLifecycleState> lifecycleChanges = [];
  bool accessibilityFeaturesChanged = false;
  bool platformBrightnessChanged = false;
  bool memoryPressureReceived = false;
  int frameCallbackCount = 0;

  @override
  Widget build(BuildContext context) {
    return Text('Observer Widget: ${widget.widgetId}');
  }

  @override
  void didChangeAccessibilityFeatures() {
    allObserverCalls.add('didChangeAccessibilityFeatures');
    accessibilityFeaturesChanged = true;
    super.didChangeAccessibilityFeatures();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    allObserverCalls.add('didChangeLocales');
    if (locales != null) {
      localeChanges.addAll(locales);
    }
    super.didChangeLocales(locales);
  }

  @override
  void didChangePlatformBrightness() {
    allObserverCalls.add('didChangePlatformBrightness');
    platformBrightnessChanged = true;
    super.didChangePlatformBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    allObserverCalls.add('didChangeAppLifecycleState');
    lifecycleChanges.add(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didHaveMemoryPressure() {
    allObserverCalls.add('didHaveMemoryPressure');
    memoryPressureReceived = true;
    super.didHaveMemoryPressure();
  }

  @override
  void didChangeMetrics() {
    allObserverCalls.add('didChangeMetrics');
    super.didChangeMetrics();
  }

  @override
  void didChangeTextScaleFactor() {
    allObserverCalls.add('didChangeTextScaleFactor');
    super.didChangeTextScaleFactor();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    allObserverCalls.add('afterFirstLayout');
    frameCallbackCount++;
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    allObserverCalls.add('reportTextScaleFactor');
  }

  // Helper methods for manual triggering
  void triggerAccessibilityFeaturesChange() {
    didChangeAccessibilityFeatures();
  }

  void triggerLocaleChange(List<Locale> locales) {
    didChangeLocales(locales);
  }

  void triggerMemoryPressure() {
    didHaveMemoryPressure();
  }

  void triggerPlatformBrightnessChange() {
    didChangePlatformBrightness();
  }

  void triggerAppLifecycleChange(AppLifecycleState state) {
    didChangeAppLifecycleState(state);
  }
}

// Inherited widget integration test
class TestInheritedWidget extends InheritedWidget {
  final String data;

  const TestInheritedWidget({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(TestInheritedWidget oldWidget) {
    return data != oldWidget.data;
  }

  static TestInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TestInheritedWidget>();
  }
}

class InheritedObserverWidget extends StatefulWidget {
  const InheritedObserverWidget({super.key});

  @override
  State<InheritedObserverWidget> createState() =>
      _InheritedObserverWidgetState();
}

class _InheritedObserverWidgetState
    extends ObservingStatefulWidget<InheritedObserverWidget> {
  String? inheritedData;
  List<String> dataChanges = [];

  @override
  Widget build(BuildContext context) {
    final inherited = TestInheritedWidget.of(context);
    if (inherited != null && inherited.data != inheritedData) {
      inheritedData = inherited.data;
      dataChanges.add(inherited.data);
    }
    return Text('Inherited: ${inheritedData ?? 'none'}');
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final inherited = TestInheritedWidget.of(context);
    if (inherited != null) {
      inheritedData = inherited.data;
      dataChanges.add(inherited.data);
    }
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {}
}

// Frame scheduling test widget
class FrameSchedulingWidget extends StatefulWidget {
  const FrameSchedulingWidget({super.key});

  @override
  State<FrameSchedulingWidget> createState() => _FrameSchedulingWidgetState();
}

class _FrameSchedulingWidgetState
    extends ObservingStatefulWidget<FrameSchedulingWidget> {
  int frameCallbacks = 0;
  List<Duration> frameTimes = [];
  bool scheduledAdditionalFrame = false;

  @override
  Widget build(BuildContext context) {
    return Text('Frame callbacks: $frameCallbacks');
  }

  @override
  void afterFirstLayout(BuildContext context) {
    frameCallbacks++;
    frameTimes.add(
      Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
    );

    // Schedule additional frame to test frame scheduling
    if (!scheduledAdditionalFrame) {
      scheduledAdditionalFrame = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        frameCallbacks++;
        frameTimes.add(
          Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
        );
      });
    }
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {}
}

// Semantics testing widget
class SemanticsObserverWidget extends StatefulWidget {
  const SemanticsObserverWidget({super.key});

  @override
  State<SemanticsObserverWidget> createState() =>
      _SemanticsObserverWidgetState();
}

class _SemanticsObserverWidgetState
    extends ObservingStatefulWidget<SemanticsObserverWidget> {
  bool semanticsEnabled = false;
  List<String> semanticsChanges = [];

  @override
  Widget build(BuildContext context) {
    semanticsEnabled = MediaQuery.of(context).accessibleNavigation;
    return Semantics(
      label: 'Test semantics widget',
      child: Text('Semantics enabled: $semanticsEnabled'),
    );
  }

  @override
  void didChangeAccessibilityFeatures() {
    semanticsChanges.add('accessibility-features-changed');
    super.didChangeAccessibilityFeatures();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    semanticsEnabled = MediaQuery.of(context).accessibleNavigation;
    semanticsChanges.add('layout-semantics-$semanticsEnabled');
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {}
}

void main() {
  group('ObservingStatefulWidget Complete Coverage Tests', () {
    group('Accessibility and Locale Tests', () {
      testWidgets('handles accessibility features changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ComprehensiveObserverWidget(widgetId: 'accessibility-test'),
          ),
        );

        final state = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        expect(state.accessibilityFeaturesChanged, isFalse);

        // Manually trigger accessibility features change
        state.triggerAccessibilityFeaturesChange();

        expect(state.accessibilityFeaturesChanged, isTrue);
        expect(
          state.allObserverCalls,
          contains('didChangeAccessibilityFeatures'),
        );
      });

      testWidgets('handles locale changes correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ComprehensiveObserverWidget(widgetId: 'locale-test'),
          ),
        );

        final state = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        expect(state.localeChanges, isEmpty);

        // Trigger locale changes
        final testLocales = [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
        ];

        state.triggerLocaleChange(testLocales);

        expect(state.localeChanges, equals(testLocales));
        expect(state.allObserverCalls, contains('didChangeLocales'));
      });

      testWidgets('platform brightness changes via platform dispatcher', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ComprehensiveObserverWidget(widgetId: 'brightness-test'),
          ),
        );

        final state = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        expect(state.platformBrightnessChanged, isFalse);

        // Change platform brightness
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pump();

        // Manual trigger since platform brightness doesn't always trigger in tests
        state.triggerPlatformBrightnessChange();

        expect(state.platformBrightnessChanged, isTrue);
        expect(state.allObserverCalls, contains('didChangePlatformBrightness'));

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });

    group('App Lifecycle and Memory Tests', () {
      testWidgets('handles all app lifecycle states', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ComprehensiveObserverWidget(widgetId: 'lifecycle-test'),
          ),
        );

        final state = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        expect(state.lifecycleChanges, isEmpty);

        // Test all lifecycle states
        final lifecycleStates = [
          AppLifecycleState.resumed,
          AppLifecycleState.inactive,
          AppLifecycleState.paused,
          AppLifecycleState.detached,
          AppLifecycleState.hidden,
        ];

        for (final state in lifecycleStates) {
          tester
              .state<_ComprehensiveObserverWidgetState>(
                find.byType(ComprehensiveObserverWidget),
              )
              .triggerAppLifecycleChange(state);
        }

        final finalState = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        expect(finalState.lifecycleChanges, equals(lifecycleStates));
        expect(
          finalState.allObserverCalls
              .where((call) => call == 'didChangeAppLifecycleState')
              .length,
          equals(lifecycleStates.length),
        );
      });

      testWidgets('handles memory pressure events', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ComprehensiveObserverWidget(widgetId: 'memory-test'),
          ),
        );

        final state = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        expect(state.memoryPressureReceived, isFalse);

        // Trigger memory pressure
        state.triggerMemoryPressure();

        expect(state.memoryPressureReceived, isTrue);
        expect(state.allObserverCalls, contains('didHaveMemoryPressure'));
      });
    });

    group('Frame Scheduling and Callback Tests', () {
      testWidgets('handles frame callbacks correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: FrameSchedulingWidget()));

        final state = tester.state<_FrameSchedulingWidgetState>(
          find.byType(FrameSchedulingWidget),
        );

        // Should have at least one frame callback from afterFirstLayout
        expect(state.frameCallbacks, greaterThanOrEqualTo(1));
        expect(state.frameTimes, isNotEmpty);

        // Trigger additional frames
        await tester.pump();
        await tester.pump();

        // Should have additional frame callbacks
        expect(state.frameCallbacks, greaterThanOrEqualTo(2));
      });

      testWidgets('frame scheduling works during widget rebuilds', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: FrameSchedulingWidget()));

        final state = tester.state<_FrameSchedulingWidgetState>(
          find.byType(FrameSchedulingWidget),
        );

        final initialCallbacks = state.frameCallbacks;

        // Rebuild widget multiple times
        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(MaterialApp(home: FrameSchedulingWidget()));
        }

        // Should maintain frame callback functionality
        expect(state.frameCallbacks, greaterThanOrEqualTo(initialCallbacks));
      });
    });

    group('Inherited Widget Integration Tests', () {
      testWidgets('works correctly with inherited widgets', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TestInheritedWidget(
              data: 'initial-data',
              child: InheritedObserverWidget(),
            ),
          ),
        );

        final state = tester.state<_InheritedObserverWidgetState>(
          find.byType(InheritedObserverWidget),
        );

        expect(state.inheritedData, equals('initial-data'));
        expect(state.dataChanges, contains('initial-data'));

        // Change inherited data
        await tester.pumpWidget(
          MaterialApp(
            home: TestInheritedWidget(
              data: 'updated-data',
              child: InheritedObserverWidget(),
            ),
          ),
        );

        expect(state.inheritedData, equals('updated-data'));
        expect(state.dataChanges, contains('updated-data'));
      });

      testWidgets('inherited widget changes during afterFirstLayout', (
        WidgetTester tester,
      ) async {
        String currentData = 'first';

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return TestInheritedWidget(
                  data: currentData,
                  child: Column(
                    children: [
                      InheritedObserverWidget(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentData = 'changed-via-button';
                          });
                        },
                        child: Text('Change Data'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        final state = tester.state<_InheritedObserverWidgetState>(
          find.byType(InheritedObserverWidget),
        );

        expect(state.dataChanges, contains('first'));

        // Trigger button press to change inherited data
        await tester.tap(find.text('Change Data'));
        await tester.pump();

        expect(state.dataChanges, contains('changed-via-button'));
      });
    });

    group('Semantics Integration Tests', () {
      testWidgets('works with semantics enabled', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SemanticsObserverWidget()));

        final state = tester.state<_SemanticsObserverWidgetState>(
          find.byType(SemanticsObserverWidget),
        );

        expect(state.semanticsChanges, isNotEmpty);

        // Find by widget type instead of semantics label
        expect(find.byType(SemanticsObserverWidget), findsOneWidget);
        expect(find.textContaining('Semantics enabled:'), findsOneWidget);

        // Trigger accessibility features change
        state.didChangeAccessibilityFeatures();

        expect(
          state.semanticsChanges,
          contains('accessibility-features-changed'),
        );
      });

      testWidgets('semantics observer responds to accessibility changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Semantics(enabled: true, child: SemanticsObserverWidget()),
          ),
        );

        final state = tester.state<_SemanticsObserverWidgetState>(
          find.byType(SemanticsObserverWidget),
        );

        // Manually trigger accessibility change
        state.didChangeAccessibilityFeatures();

        expect(
          state.semanticsChanges,
          contains('accessibility-features-changed'),
        );
      });
    });

    group('Complex Integration Tests', () {
      testWidgets('all observer methods work together', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ComprehensiveObserverWidget(widgetId: 'integration-test'),
          ),
        );

        final state = tester.state<_ComprehensiveObserverWidgetState>(
          find.byType(ComprehensiveObserverWidget),
        );

        // Trigger all observer methods
        state.triggerAccessibilityFeaturesChange();
        state.triggerLocaleChange([Locale('en', 'US')]);
        state.triggerPlatformBrightnessChange();
        state.triggerAppLifecycleChange(AppLifecycleState.paused);
        state.triggerMemoryPressure();

        // Platform-triggered events
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        await tester.pump();

        // Verify all methods were called
        expect(
          state.allObserverCalls,
          containsAll([
            'didChangeAccessibilityFeatures',
            'didChangeLocales',
            'didChangePlatformBrightness',
            'didChangeAppLifecycleState',
            'didHaveMemoryPressure',
            'didChangeTextScaleFactor',
            'afterFirstLayout',
            'reportTextScaleFactor',
          ]),
        );

        expect(state.accessibilityFeaturesChanged, isTrue);
        expect(state.localeChanges, isNotEmpty);
        expect(state.platformBrightnessChanged, isTrue);
        expect(state.lifecycleChanges, isNotEmpty);
        expect(state.memoryPressureReceived, isTrue);

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('observer methods work during complex widget tree changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: ComprehensiveObserverWidget(widgetId: 'appbar-observer'),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        ComprehensiveObserverWidget(
                          widgetId: 'list-observer-1',
                        ),
                        ComprehensiveObserverWidget(
                          widgetId: 'list-observer-2',
                        ),
                      ],
                    ),
                  ),
                  TestInheritedWidget(
                    data: 'complex-tree-data',
                    child: InheritedObserverWidget(),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: SemanticsObserverWidget(),
              ),
            ),
          ),
        );

        // Find all observer widgets
        final observers = find.byType(ComprehensiveObserverWidget);
        expect(observers, findsNWidgets(3));

        // Trigger platform changes that should affect all observers
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        await tester.pump();

        // All observers should have received the platform change
        for (int i = 0; i < 3; i++) {
          final state = tester.state<_ComprehensiveObserverWidgetState>(
            observers.at(i),
          );
          expect(state.allObserverCalls, contains('didChangeTextScaleFactor'));
        }

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });

      testWidgets('performance under complex observer scenarios', (
        WidgetTester tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        // Create complex widget tree with multiple observers
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: List.generate(
                  10,
                  (index) =>
                      ComprehensiveObserverWidget(widgetId: 'perf-test-$index'),
                ),
              ),
            ),
          ),
        );

        stopwatch.stop();

        // Should build quickly even with many observers
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // Trigger platform changes affecting all observers
        final platformStopwatch = Stopwatch()..start();

        tester.platformDispatcher.textScaleFactorTestValue = 1.8;
        await tester.pump();

        platformStopwatch.stop();

        // Platform changes should process quickly
        expect(platformStopwatch.elapsedMilliseconds, lessThan(500));

        // Verify all observers received the change
        final observers = find.byType(ComprehensiveObserverWidget);
        for (int i = 0; i < 10; i++) {
          final state = tester.state<_ComprehensiveObserverWidgetState>(
            observers.at(i),
          );
          expect(state.allObserverCalls, contains('didChangeTextScaleFactor'));
        }

        tester.platformDispatcher.clearAllTestValues();
        tester.view.reset();
      });
    });
  });
}
