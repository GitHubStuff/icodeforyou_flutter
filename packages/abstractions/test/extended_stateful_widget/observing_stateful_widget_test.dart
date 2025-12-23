// observing_stateful_widget_2_test.dart
import 'package:abstractions/abstractions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProbeWidget extends StatefulWidget {
  const _ProbeWidget({super.key});

  @override
  State<_ProbeWidget> createState() => _ProbeWidgetState();
}

class _ProbeWidgetState extends ExtendedStatefulWidget<_ProbeWidget> {
  int afterFirstLayoutCount = 0;
  int reportCalls = 0;
  double? lastReportedScale;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);
    afterFirstLayoutCount++;
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    super.reportTextScaleFactor(textScaleFactor);
    reportCalls++;
    lastReportedScale = textScaleFactor;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('afterFirstLayout is called once after first frame', (
    tester,
  ) async {
    final key = GlobalKey<_ProbeWidgetState>();

    await tester.pumpWidget(MaterialApp(home: _ProbeWidget(key: key)));
    // First pump schedules post-frame; second pump runs it.
    await tester.pump();

    final state = key.currentState!;
    expect(state.afterFirstLayoutCount, 1);
  });

  testWidgets(
    'reportTextScaleFactor called on init + didChangeTextScaleFactor',
    (tester) async {
      final key = GlobalKey<_ProbeWidgetState>();

      await tester.pumpWidget(MaterialApp(home: _ProbeWidget(key: key)));

      final state = key.currentState!;
      final initialScale = tester.binding.platformDispatcher.textScaleFactor;

      // Called once from initState()
      expect(state.reportCalls, 1);
      expect(state.lastReportedScale, initialScale);

      // Trigger observer callback manually; should call again.
      state.didChangeTextScaleFactor();
      await tester.pump();

      expect(state.reportCalls, 2);
      expect(
        state.lastReportedScale,
        tester.binding.platformDispatcher.textScaleFactor,
      );
    },
  );
}
