// packages/sincewhen_models/test/src/repositories/since_when_item_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/src/models/since_when_item.dart';
import 'package:sincewhen_models/src/repositories/since_when_repository.dart';

/// A fake implementation to satisfy the interface contract for testing purposes.
class FakeSinceWhenRepository implements SinceWhenRepository {
  @override
  Future<List<SinceWhenItem>> allItems() async => [];

  @override
  Stream<List<SinceWhenItem>> watchAllItems() => const Stream.empty();

  @override
  Future<SinceWhenItem?> itemByCreatedTimestamp(int createdTimestamp) async =>
      null;

  @override
  Future<int> itemCount() async => 0;

  @override
  Stream<int> watchItemCount() => const Stream.empty();

  @override
  Future<SinceWhenItem> insertItem(SinceWhenItem item) async => item;

  @override
  Future<bool> updateItem(SinceWhenItem item) async => true;

  @override
  Future<bool> deleteItem(SinceWhenItem item) async => true;
}

void main() {
  group('SinceWhenRepository interface', () {
    test('can be implemented and fulfills the defined contract', () async {
      // Instantiate the fake but type it as the abstract interface
      final SinceWhenRepository repository = FakeSinceWhenRepository();

      const dummyItem = SinceWhenItem(
        id: 1,
        createdTimestamp: 1672531200000,
        reviewedTimestamp: 1672531200000,
        editedTimestamp: 1672531200000,
        sequenceNumber: 0,
        content: 'Test content',
      );

      // Verify all method signatures resolve correctly
      expect(await repository.allItems(), isA<List<SinceWhenItem>>());
      expect(repository.watchAllItems(), isA<Stream<List<SinceWhenItem>>>());
      expect(await repository.itemByCreatedTimestamp(1672531200000), isNull);
      expect(await repository.itemCount(), isZero);
      expect(repository.watchItemCount(), isA<Stream<int>>());
      expect(await repository.insertItem(dummyItem), equals(dummyItem));
      expect(await repository.updateItem(dummyItem), isTrue);
      expect(await repository.deleteItem(dummyItem), isTrue);
    });
  });
}
