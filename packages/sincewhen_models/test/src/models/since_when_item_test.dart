// packages/sincewhen_models/test/src/models/since_when_item_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/src/models/since_when_item.dart';

void main() {
  group('SinceWhenItem', () {
    const id = 1;
    const createdTimestamp = 1000;
    const reviewedTimestamp = 2000;
    const editedTimestamp = 3000;
    const sequenceNumber = 0;
    const content = 'Initial content';
    
    const parentTimestamp = 500;
    const eventTimestamp = 600;
    const metaData = '{"key":"value"}';
    const tldr = 'Short summary';

    const minimalItem = SinceWhenItem(
      id: id,
      createdTimestamp: createdTimestamp,
      reviewedTimestamp: reviewedTimestamp,
      editedTimestamp: editedTimestamp,
      sequenceNumber: sequenceNumber,
      content: content,
    );

    const fullItem = SinceWhenItem(
      id: id,
      createdTimestamp: createdTimestamp,
      reviewedTimestamp: reviewedTimestamp,
      editedTimestamp: editedTimestamp,
      sequenceNumber: sequenceNumber,
      content: content,
      parentTimestamp: parentTimestamp,
      eventTimestamp: eventTimestamp,
      metaData: metaData,
      tldr: tldr,
    );

    test('can be instantiated with only required fields', () {
      expect(minimalItem.id, equals(id));
      expect(minimalItem.parentTimestamp, isNull);
    });

    test('can be instantiated with all fields', () {
      expect(fullItem.parentTimestamp, equals(parentTimestamp));
      expect(fullItem.tldr, equals(tldr));
    });

    test('supports value equality', () {
      const item2 = SinceWhenItem(
        id: id,
        createdTimestamp: createdTimestamp,
        reviewedTimestamp: reviewedTimestamp,
        editedTimestamp: editedTimestamp,
        sequenceNumber: sequenceNumber,
        content: content,
      );

      expect(minimalItem, equals(item2));
      expect(minimalItem == item2, isTrue);
      expect(minimalItem, isNot(equals(fullItem)));
    });

    test('props contains all fields in order', () {
      expect(
        fullItem.props,
        equals([
          id,
          createdTimestamp,
          reviewedTimestamp,
          editedTimestamp,
          sequenceNumber,
          content,
          parentTimestamp,
          eventTimestamp,
          metaData,
          tldr,
        ]),
      );
    });

    test('stringify is true and formats toString() correctly', () {
      expect(minimalItem.stringify, isTrue);
      expect(
        minimalItem.toString(),
        contains('SinceWhenItem'),
      );
    });

    group('copyWith', () {
      test('returns an identical instance when no arguments are provided', () {
        final copiedItem = fullItem.copyWith();
        
        expect(copiedItem, equals(fullItem));
      });

      test('updates required fields with new values', () {
        const newId = 2;
        const newCreated = 1001;
        const newReviewed = 2001;
        const newEdited = 3001;
        const newSequence = 1;
        const newContent = 'Updated content';

        final copiedItem = minimalItem.copyWith(
          id: newId,
          createdTimestamp: newCreated,
          reviewedTimestamp: newReviewed,
          editedTimestamp: newEdited,
          sequenceNumber: newSequence,
          content: newContent,
        );

        expect(copiedItem.id, equals(newId));
        expect(copiedItem.createdTimestamp, equals(newCreated));
        expect(copiedItem.reviewedTimestamp, equals(newReviewed));
        expect(copiedItem.editedTimestamp, equals(newEdited));
        expect(copiedItem.sequenceNumber, equals(newSequence));
        expect(copiedItem.content, equals(newContent));
        
        // Nullable fields should remain untouched (null)
        expect(copiedItem.parentTimestamp, isNull);
      });

      test('updates nullable fields with new non-null values', () {
        final copiedItem = minimalItem.copyWith(
          parentTimestamp: parentTimestamp,
          eventTimestamp: eventTimestamp,
          metaData: metaData,
          tldr: tldr,
        );

        expect(copiedItem.parentTimestamp, equals(parentTimestamp));
        expect(copiedItem.eventTimestamp, equals(eventTimestamp));
        expect(copiedItem.metaData, equals(metaData));
        expect(copiedItem.tldr, equals(tldr));
      });

      test('explicitly clears nullable fields when passed null', () {
        // Here we pass `null` to clear the values from `fullItem`.
        // This exercises the `== _unset` false branches in `copyWith`.
        final copiedItem = fullItem.copyWith(
          parentTimestamp: null,
          eventTimestamp: null,
          metaData: null,
          tldr: null,
        );

        expect(copiedItem.parentTimestamp, isNull);
        expect(copiedItem.eventTimestamp, isNull);
        expect(copiedItem.metaData, isNull);
        expect(copiedItem.tldr, isNull);
        
        // Ensure other fields were not affected
        expect(copiedItem.id, equals(fullItem.id));
      });
    });
  });
}
