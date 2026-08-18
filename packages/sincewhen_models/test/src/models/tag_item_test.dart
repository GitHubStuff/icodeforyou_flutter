// packages/sincewhen_models/test/src/models/tag_item_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/src/models/tag_item.dart';

void main() {
  group('TagItem', () {
    const id = 1;
    const recordTimestamp = 1672531200000;
    const glossaryTimestamp = 1672617600000;

    const item = TagItem(
      id: id,
      recordTimestamp: recordTimestamp,
      glossaryTimestamp: glossaryTimestamp,
    );

    test('can be instantiated and properties are set correctly', () {
      expect(item.id, equals(id));
      expect(item.recordTimestamp, equals(recordTimestamp));
      expect(item.glossaryTimestamp, equals(glossaryTimestamp));
    });

    test('supports value equality', () {
      const item2 = TagItem(
        id: id,
        recordTimestamp: recordTimestamp,
        glossaryTimestamp: glossaryTimestamp,
      );

      const differentItem = TagItem(
        id: 2,
        recordTimestamp: 1000,
        glossaryTimestamp: 2000,
      );

      expect(item, equals(item2));
      expect(item == item2, isTrue);
      expect(item, isNot(equals(differentItem)));
    });

    test('props contains all fields in order', () {
      expect(
        item.props,
        equals([id, recordTimestamp, glossaryTimestamp]),
      );
    });

    test('stringify is true and formats toString() correctly', () {
      expect(item.stringify, isTrue);
      expect(
        item.toString(),
        equals('TagItem($id, $recordTimestamp, $glossaryTimestamp)'),
      );
    });

    group('copyWith', () {
      test('returns an identical instance when no arguments are provided', () {
        final copiedItem = item.copyWith();

        expect(copiedItem, equals(item));
        expect(copiedItem.id, equals(id));
        expect(copiedItem.recordTimestamp, equals(recordTimestamp));
        expect(copiedItem.glossaryTimestamp, equals(glossaryTimestamp));
      });

      test(
        'returns a new instance with updated properties when arguments are provided',
        () {
          const newId = 2;
          const newRecordTimestamp = 999999999;
          const newGlossaryTimestamp = 888888888;

          final copiedItem = item.copyWith(
            id: newId,
            recordTimestamp: newRecordTimestamp,
            glossaryTimestamp: newGlossaryTimestamp,
          );

          expect(
            copiedItem,
            equals(
              const TagItem(
                id: newId,
                recordTimestamp: newRecordTimestamp,
                glossaryTimestamp: newGlossaryTimestamp,
              ),
            ),
          );

          // Explicitly check fields to ensure the ?? fallback worked correctly
          expect(copiedItem.id, equals(newId));
          expect(copiedItem.recordTimestamp, equals(newRecordTimestamp));
          expect(copiedItem.glossaryTimestamp, equals(newGlossaryTimestamp));
        },
      );
    });
  });
}
