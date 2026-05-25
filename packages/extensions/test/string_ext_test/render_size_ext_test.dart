// extensions/test/src/render_size_ext_test.dart

import 'package:extensions/extensions.dart' show StringExt;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExt.renderSize', () {
    testWidgets('returns positive dimensions for non-empty string', (
      tester,
    ) async {
      const text = 'Hello';
      final size = text.renderSize();
      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
    });

    testWidgets('returns zero width for empty string', (tester) async {
      const text = '';
      final size = text.renderSize();
      expect(size.width, 0);
      expect(size.height, greaterThan(0));
    });

    testWidgets('respects fontSize parameter', (tester) async {
      const text = 'Hello';
      final small = text.renderSize(fontSize: 10);
      final large = text.renderSize(fontSize: 40);
      expect(large.height, greaterThan(small.height));
    });

    testWidgets('respects fontWeight parameter', (tester) async {
      const text = 'Hello';
      final normal = text.renderSize();
      final bold = text.renderSize(fontWeight: FontWeight.bold);
      expect(bold.width, greaterThanOrEqualTo(normal.width));
    });

    testWidgets('respects maxLines parameter', (tester) async {
      const text = 'Hello World this is a long string that wraps';
      final oneLine = text.renderSize(maxLines: 1, fontSize: 200);
      final twoLines = text.renderSize(maxLines: 2, fontSize: 200);
      expect(twoLines.height, greaterThanOrEqualTo(oneLine.height));
    });

    testWidgets('respects textDirection rtl', (tester) async {
      const text = 'Hello';
      final size = text.renderSize(textDirection: TextDirection.rtl);
      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
    });
  });
}
