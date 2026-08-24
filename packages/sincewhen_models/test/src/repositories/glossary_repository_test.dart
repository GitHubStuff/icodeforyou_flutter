// packages/sincewhen_models/test/src/repositories/glossary_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/src/models/glossary_item.dart';
import 'package:sincewhen_models/src/repositories/glossary_repository.dart';

/// A fake implementation to satisfy the interface contract for testing purposes.
class FakeGlossaryRepository implements GlossaryRepository {
  @override
  Future<List<GlossaryItem>> allItems() async => [];

  @override
  Stream<List<GlossaryItem>> watchAllItems() => const Stream.empty();

  @override
  Future<Set<int>> allColorArgbValues() async => <int>{};

  @override
  Future<GlossaryItem?> itemByTag(String tag) async => null;

  @override
  Future<GlossaryItem?> itemWithColor(int colorArgb) async => null;

  @override
  Future<int> itemCount() async => 0;

  @override
  Stream<int> watchItemCount() => const Stream.empty();

  @override
  Future<GlossaryItem> insertItem(GlossaryItem item) async => item;

  @override
  Future<bool> updateItem(GlossaryItem item) async => true;

  @override
  Future<bool> deleteItem(GlossaryItem item) async => true;
}

void main() {
  group('GlossaryRepository interface', () {
    test('can be implemented and fulfills the defined contract', () async {
      // Instantiate the fake but type it as the abstract interface
      final GlossaryRepository repository = FakeGlossaryRepository();

      const dummyItem = GlossaryItem(
        id: 1,
        createdTimestamp: 1672531200000,
        tag: 'Test',
        colorArgb: 0xFFFFFFFF,
        descr: 'Test Description',
      );

      // Verify all method signatures resolve correctly
      expect(await repository.allItems(), isA<List<GlossaryItem>>());
      expect(repository.watchAllItems(), isA<Stream<List<GlossaryItem>>>());
      expect(await repository.allColorArgbValues(), isA<Set<int>>());
      expect(await repository.itemByTag('Test'), isNull);
      expect(await repository.itemWithColor(0xFFFFFFFF), isNull);
      expect(await repository.itemCount(), isZero);
      expect(repository.watchItemCount(), isA<Stream<int>>());
      expect(await repository.insertItem(dummyItem), equals(dummyItem));
      expect(await repository.updateItem(dummyItem), isTrue);
      expect(await repository.deleteItem(dummyItem), isTrue);
    });
  });
}
