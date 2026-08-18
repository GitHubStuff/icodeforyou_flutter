// packages/sincewhen_models/test/src/models/glossary_item_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/src/models/glossary_item.dart';

void main() {
  group('GlossaryItem', () {
    const id = 1;
    const createdTimestamp = 1672531200000;
    const tag = 'Health';
    const colorArgb = 0xFFE53935;

    const item = GlossaryItem(
      id: id,
      createdTimestamp: createdTimestamp,
      tag: tag,
      colorArgb: colorArgb,
    );

    test('can be instantiated', () {
      expect(item.id, equals(id));
      expect(item.createdTimestamp, equals(createdTimestamp));
      expect(item.tag, equals(tag));
      expect(item.colorArgb, equals(colorArgb));
    });

    test('supports value equality', () {
      const item2 = GlossaryItem(
        id: id,
        createdTimestamp: createdTimestamp,
        tag: tag,
        colorArgb: colorArgb,
      );

      expect(item, equals(item2));
      expect(item == item2, isTrue);
    });

    test('props contains all fields in order', () {
      expect(
        item.props,
        equals([id, createdTimestamp, tag, colorArgb]),
      );
    });

    test('stringify is true and formats toString() correctly', () {
      expect(item.stringify, isTrue);
      expect(
        item.toString(),
        equals('GlossaryItem($id, $createdTimestamp, $tag, $colorArgb)'),
      );
    });

    group('copyWith', () {
      test('returns an identical instance when no arguments are provided', () {
        final copiedItem = item.copyWith();

        expect(copiedItem, equals(item));
        expect(copiedItem.id, equals(id));
        expect(copiedItem.createdTimestamp, equals(createdTimestamp));
        expect(copiedItem.tag, equals(tag));
        expect(copiedItem.colorArgb, equals(colorArgb));
      });

      test(
        'returns a new instance with updated properties when arguments are provided',
        () {
          const newId = 2;
          const newTimestamp = 1672617600000;
          const newTag = 'Work';
          const newColor = 0xFF1E88E5;

          final copiedItem = item.copyWith(
            id: newId,
            createdTimestamp: newTimestamp,
            tag: newTag,
            colorArgb: newColor,
          );

          expect(
            copiedItem,
            equals(
              const GlossaryItem(
                id: newId,
                createdTimestamp: newTimestamp,
                tag: newTag,
                colorArgb: newColor,
              ),
            ),
          );

          // Explicitly check fields to ensure the ?? fallback worked correctly
          expect(copiedItem.id, equals(newId));
          expect(copiedItem.createdTimestamp, equals(newTimestamp));
          expect(copiedItem.tag, equals(newTag));
          expect(copiedItem.colorArgb, equals(newColor));
        },
      );
    });
  });
}
