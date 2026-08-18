// packages/sincewhen_models/test/src/repositories/tag_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/src/models/tag_item.dart';
import 'package:sincewhen_models/src/repositories/tag_repository.dart';

/// A fake implementation to satisfy the interface contract for testing purposes.
class FakeTagRepository implements TagRepository {
  @override
  Future<List<TagItem>> allItems() async => [];

  @override
  Stream<List<TagItem>> watchAllItems() => const Stream.empty();

  @override
  Future<List<TagItem>> itemsForRecord(int recordTimestamp) async => [];

  @override
  Stream<List<TagItem>> watchItemsForRecord(int recordTimestamp) =>
      const Stream.empty();

  @override
  Future<List<TagItem>> itemsForGlossary(int glossaryTimestamp) async => [];

  @override
  Future<int> itemCount() async => 0;

  @override
  Stream<int> watchItemCount() => const Stream.empty();

  @override
  Future<TagItem> insertItem(TagItem item) async => item;

  @override
  Future<bool> deleteItem(TagItem item) async => true;
}

void main() {
  group('TagRepository interface', () {
    test('can be implemented and fulfills the defined contract', () async {
      // Instantiate the fake but type it as the abstract interface
      final TagRepository repository = FakeTagRepository();

      const dummyItem = TagItem(
        id: 1,
        recordTimestamp: 1672531200000,
        glossaryTimestamp: 1672617600000,
      );

      // Verify all method signatures resolve correctly
      expect(await repository.allItems(), isA<List<TagItem>>());
      expect(repository.watchAllItems(), isA<Stream<List<TagItem>>>());
      expect(
        await repository.itemsForRecord(1672531200000),
        isA<List<TagItem>>(),
      );
      expect(
        repository.watchItemsForRecord(1672531200000),
        isA<Stream<List<TagItem>>>(),
      );
      expect(
        await repository.itemsForGlossary(1672617600000),
        isA<List<TagItem>>(),
      );
      expect(await repository.itemCount(), isZero);
      expect(repository.watchItemCount(), isA<Stream<int>>());
      expect(await repository.insertItem(dummyItem), equals(dummyItem));
      expect(await repository.deleteItem(dummyItem), isTrue);
    });
  });
}
