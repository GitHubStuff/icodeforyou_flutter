// packages/custom_widgets/test/src/sized_spinner/sized_spinner_test.dart

import 'package:custom_widgets/custom_widgets.dart' show SizedSpinner;
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/platform_utils.dart' show PlatformVendor;

/// The spinner diameter used across tests.
const double _kSize = 40;

/// Pumps [spinner] inside a Material scaffold.
Future<void> _pump(WidgetTester tester, SizedSpinner spinner) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: spinner))),
  );
}

void main() {
  group('SizedSpinner', () {
    testWidgets('apple renders a Cupertino indicator at half-size radius',
        (tester) async {
      await _pump(
        tester,
        const SizedSpinner(
          size: _kSize,
          color: Colors.pink,
          platformVendor: PlatformVendor.apple,
        ),
      );
      await tester.pump();

      final indicator = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(indicator.radius, _kSize / 2);
      expect(indicator.color, Colors.pink);
      expect(indicator.animating, isTrue);
    });

    for (final vendor in const [
      PlatformVendor.google,
      PlatformVendor.microsoft,
      PlatformVendor.other,
    ]) {
      testWidgets('$vendor renders a sized Material indicator',
          (tester) async {
        await _pump(
          tester,
          SizedSpinner(
            size: _kSize,
            color: Colors.pink,
            platformVendor: vendor,
          ),
        );
        await tester.pump();

        final box = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(box.width, _kSize);
        expect(box.height, _kSize);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, Colors.pink);
        expect(indicator.strokeWidth, _kSize * 0.07);
      });
    }

    testWidgets('a null platformVendor falls back to the current vendor',
        (tester) async {
      await _pump(tester, const SizedSpinner(size: _kSize));
      await tester.pump();

      final cupertino = find.byType(CupertinoActivityIndicator);
      final material = find.byType(CircularProgressIndicator);
      expect(
        cupertino.evaluate().length + material.evaluate().length,
        1,
      );
    });
  });
}
