// packages/curated_widgets/test/curated_widgets_test.dart

import 'package:test/test.dart';

import '../../lib/curated_widgets.dart' show CuratedWidgets;

void main() {
  group('CuratedWidgets', () {
    late CuratedWidgets curatedWidgets;

    setUp(() {
      curatedWidgets = CuratedWidgets();
    });

    test('can be instantiated', () {
      expect(curatedWidgets, isA<CuratedWidgets>());
    });
  });
}
