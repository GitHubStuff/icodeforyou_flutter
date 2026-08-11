// packages/custom_widgets/test/src/uniform_cluster/uniform_cluster_test.dart

import 'package:custom_widgets/custom_widgets.dart' show UniformCluster;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keys for the two children under test.
const Key _kFirstKey = Key('first');
const Key _kSecondKey = Key('second');

/// Pumps [cluster] inside a Material scaffold constrained to [width].
Future<void> _pump(
  WidgetTester tester,
  UniformCluster cluster, {
  double width = 300,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: cluster)),
      ),
    ),
  );
}

void main() {
  group('UniformCluster', () {
    testWidgets('horizontal gives each child an equal share of the width',
        (tester) async {
      await _pump(
        tester,
        const UniformCluster(
          children: [
            Text('a', key: _kFirstKey),
            Text('a much longer label', key: _kSecondKey),
          ],
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(2));
      expect(
        tester.getSize(find.byKey(_kFirstKey)).width,
        tester.getSize(find.byKey(_kSecondKey)).width,
      );
    });

    testWidgets('vertical stretches every child to the widest intrinsic '
        'width', (tester) async {
      await _pump(
        tester,
        const UniformCluster(
          axis: Axis.vertical,
          children: [
            Text('a', key: _kFirstKey),
            Text('a much longer label', key: _kSecondKey),
          ],
        ),
      );

      expect(find.byType(IntrinsicWidth), findsOneWidget);
      final column = tester.widget<Column>(find.byType(Column).last);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(
        tester.getSize(find.byKey(_kFirstKey)).width,
        tester.getSize(find.byKey(_kSecondKey)).width,
      );
    });
  });
}
