// packages/sincewhen_screens/test/src/cubit/state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/sincewhen_models.dart';
import 'package:sincewhen_screens/src/cubit/state.dart';

void main() {
  group('SinceWhenMiniAction', () {
    test('carries correct labels for all values', () {
      expect(SinceWhenMiniAction.submit.label, equals('Submit'));
      expect(SinceWhenMiniAction.update.label, equals('Update'));
      expect(SinceWhenMiniAction.reviewed.label, equals('Reviewed'));
    });
  });

  group('SinceWhenMiniLoading', () {
    test('supports value equality and has empty props', () {
      const state1 = SinceWhenMiniLoading();
      const state2 = SinceWhenMiniLoading();

      expect(state1, equals(state2));
      expect(state1.props, isEmpty);
    });
  });

  group('SinceWhenMiniReady', () {
    SinceWhenItem createItem({
      int id = 42,
      int created = 1000,
      int reviewed = 2000,
      int edited = 3000,
      int sequenceNumber = 5,
      String content = 'orig content',
      int? parentTimestamp = 999,
      int? eventTimestamp = 4000,
      String? metaData = 'orig meta',
      String? tldr = 'orig tldr',
    }) {
      return SinceWhenItem(
        id: id,
        createdTimestamp: created,
        reviewedTimestamp: reviewed,
        editedTimestamp: edited,
        sequenceNumber: sequenceNumber,
        content: content,
        parentTimestamp: parentTimestamp,
        eventTimestamp: eventTimestamp,
        metaData: metaData,
        tldr: tldr,
      );
    }

    SinceWhenMiniReady createReady({
      SinceWhenItem? original,
      int created = 1000,
      int reviewed = 2000,
      int edited = 3000,
      String content = 'orig content',
      String metaData = 'orig meta',
      String tldr = 'orig tldr',
      int? eventTimestamp = 4000,
    }) {
      return SinceWhenMiniReady(
        original: original,
        createdTimestamp: created,
        reviewedTimestamp: reviewed,
        editedTimestamp: edited,
        content: content,
        metaData: metaData,
        tldr: tldr,
        eventTimestamp: eventTimestamp,
      );
    }

    group('normalization (_normalized)', () {
      test('returns null for empty or whitespace-only strings', () {
        final ready = createReady(
          metaData: '   ',
          tldr: '',
        );

        expect(ready.normalizedMetaData, isNull);
        expect(ready.normalizedTldr, isNull);
      });

      test(
        'returns raw string unchanged when containing non-whitespace characters',
        () {
          final ready = createReady(
            metaData: '  has content  ',
            tldr: 'summary',
          );

          expect(ready.normalizedMetaData, equals('  has content  '));
          expect(ready.normalizedTldr, equals('summary'));
        },
      );
    });

    group('isCreate & sequenceNumber', () {
      test(
        'returns isCreate true and sequenceNumber 0 when original is null',
        () {
          final ready = createReady(original: null);

          expect(ready.isCreate, isTrue);
          expect(ready.sequenceNumber, equals(0));
        },
      );

      test(
        'returns isCreate false and preserves sequenceNumber when original is present',
        () {
          final item = createItem(sequenceNumber: 7);
          final ready = createReady(original: item);

          expect(ready.isCreate, isFalse);
          expect(ready.sequenceNumber, equals(7));
        },
      );
    });

    group('hasContent', () {
      test('returns false when content is empty or only whitespace', () {
        expect(createReady(content: '').hasContent, isFalse);
        expect(createReady(content: '    ').hasContent, isFalse);
      });

      test('returns true when content has visible text', () {
        expect(createReady(content: 'hello').hasContent, isTrue);
        expect(createReady(content: '  hello  ').hasContent, isTrue);
      });
    });

    group('isDirty', () {
      test('is always false in create mode (original == null)', () {
        final ready = createReady(original: null);
        expect(ready.isDirty, isFalse);
      });

      test('is false when edit draft exactly matches original', () {
        final item = createItem();
        final ready = createReady(
          original: item,
          content: item.content,
          metaData: item.metaData!,
          tldr: item.tldr!,
          eventTimestamp: item.eventTimestamp,
        );

        expect(ready.isDirty, isFalse);
      });

      test('is true when content differs', () {
        final item = createItem(content: 'old');
        final ready = createReady(original: item, content: 'new');

        expect(ready.isDirty, isTrue);
      });

      test('is true when normalizedMetaData differs from original', () {
        final item = createItem(metaData: 'saved meta');
        final ready = createReady(original: item, metaData: 'changed meta');

        expect(ready.isDirty, isTrue);
      });

      test('is true when normalizedTldr differs from original', () {
        final item = createItem(tldr: 'saved tldr');
        final ready = createReady(original: item, tldr: 'changed tldr');

        expect(ready.isDirty, isTrue);
      });

      test('is true when eventTimestamp differs from original', () {
        final item = createItem(eventTimestamp: 100);
        final ready = createReady(original: item, eventTimestamp: 200);

        expect(ready.isDirty, isTrue);
      });
    });

    group('primaryAction & isPrimaryEnabled', () {
      test(
        'create mode: primaryAction is submit; requires hasContent to enable',
        () {
          final emptyCreate = createReady(original: null, content: '   ');
          expect(emptyCreate.primaryAction, SinceWhenMiniAction.submit);
          expect(emptyCreate.isPrimaryEnabled, isFalse);

          final filledCreate = createReady(original: null, content: 'Note');
          expect(filledCreate.primaryAction, SinceWhenMiniAction.submit);
          expect(filledCreate.isPrimaryEnabled, isTrue);
        },
      );

      test(
        'edit mode without changes: primaryAction is reviewed; always enabled',
        () {
          final item = createItem(content: 'saved');
          final ready = createReady(
            original: item,
            content: 'saved',
            metaData: item.metaData!,
            tldr: item.tldr!,
            eventTimestamp: item.eventTimestamp,
          );

          expect(ready.primaryAction, SinceWhenMiniAction.reviewed);
          expect(ready.isPrimaryEnabled, isTrue);
        },
      );

      test(
        'edit mode with changes: primaryAction is update; requires hasContent to enable',
        () {
          final item = createItem(content: 'saved');

          final emptyUpdate = createReady(
            original: item,
            content: '   ',
            metaData: 'new meta',
          );
          expect(emptyUpdate.primaryAction, SinceWhenMiniAction.update);
          expect(emptyUpdate.isPrimaryEnabled, isFalse);

          final filledUpdate = createReady(
            original: item,
            content: 'new content',
          );
          expect(filledUpdate.primaryAction, SinceWhenMiniAction.update);
          expect(filledUpdate.isPrimaryEnabled, isTrue);
        },
      );
    });

    group('toItem', () {
      test(
        'builds unpersisted item with id 0 and parentTimestamp null in create mode',
        () {
          final ready = createReady(
            original: null,
            created: 111,
            content: 'new record',
            metaData: '   ', // normalizes to null
            tldr: 'summary',
            eventTimestamp: 222,
          );

          final result = ready.toItem(
            reviewedTimestamp: 333,
            editedTimestamp: 444,
          );

          expect(result.id, equals(0));
          expect(result.createdTimestamp, equals(111));
          expect(result.reviewedTimestamp, equals(333));
          expect(result.editedTimestamp, equals(444));
          expect(result.sequenceNumber, equals(0));
          expect(result.content, equals('new record'));
          expect(result.parentTimestamp, isNull);
          expect(result.eventTimestamp, equals(222));
          expect(result.metaData, isNull);
          expect(result.tldr, equals('summary'));
        },
      );

      test(
        'preserves id, sequenceNumber, and parentTimestamp from original in edit mode',
        () {
          final item = createItem(
            id: 99,
            sequenceNumber: 3,
            parentTimestamp: 888,
          );
          final ready = createReady(
            original: item,
            created: item.createdTimestamp,
            content: 'edited content',
            metaData: 'meta payload',
            tldr: '   ', // normalizes to null
            eventTimestamp: null,
          );

          final result = ready.toItem(
            reviewedTimestamp: 555,
            editedTimestamp: 666,
          );

          expect(result.id, equals(99));
          expect(result.createdTimestamp, equals(item.createdTimestamp));
          expect(result.reviewedTimestamp, equals(555));
          expect(result.editedTimestamp, equals(666));
          expect(result.sequenceNumber, equals(3));
          expect(result.content, equals('edited content'));
          expect(result.parentTimestamp, equals(888));
          expect(result.eventTimestamp, isNull);
          expect(result.metaData, equals('meta payload'));
          expect(result.tldr, isNull);
        },
      );
    });

    group('copyWith', () {
      test(
        'replaces provided fields and retains omitted fields with default sentinel',
        () {
          final original = createReady(
            content: 'c1',
            metaData: 'm1',
            tldr: 't1',
            eventTimestamp: 100,
          );

          final updated = original.copyWith(
            content: 'c2',
            metaData: 'm2',
            tldr: 't2',
          );

          expect(updated.content, equals('c2'));
          expect(updated.metaData, equals('m2'));
          expect(updated.tldr, equals('t2'));
          expect(updated.eventTimestamp, equals(100));
        },
      );

      test('explicitly clears eventTimestamp to null when null is passed', () {
        final original = createReady(eventTimestamp: 500);

        final updated = original.copyWith(eventTimestamp: null);

        expect(updated.eventTimestamp, isNull);
      });

      test('updates eventTimestamp to a new non-null value', () {
        final original = createReady(eventTimestamp: 500);

        final updated = original.copyWith(eventTimestamp: 900);

        expect(updated.eventTimestamp, equals(900));
      });
    });

    group('equality & props', () {
      test('instances with identical fields evaluate as equal', () {
        final item = createItem();
        final ready1 = createReady(original: item);
        final ready2 = createReady(original: item);

        expect(ready1, equals(ready2));
        expect(ready1.props, equals(ready2.props));
      });

      test('instances with differing fields evaluate as not equal', () {
        final item = createItem();
        final ready1 = createReady(original: item, content: 'a');
        final ready2 = createReady(original: item, content: 'b');

        expect(ready1, isNot(equals(ready2)));
      });
    });
  });
}
