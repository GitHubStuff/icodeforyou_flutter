// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_items_dao.dart';

// ignore_for_file: type=lint
mixin _$TagItemsDaoMixin on DatabaseAccessor<SinceWhenDatabase> {
  $SinceWhenItemsTable get sinceWhenItems => attachedDatabase.sinceWhenItems;
  $GlossaryItemsTable get glossaryItems => attachedDatabase.glossaryItems;
  $TagItemsTable get tagItems => attachedDatabase.tagItems;
  TagItemsDaoManager get managers => TagItemsDaoManager(this);
}

class TagItemsDaoManager {
  final _$TagItemsDaoMixin _db;
  TagItemsDaoManager(this._db);
  $$SinceWhenItemsTableTableManager get sinceWhenItems =>
      $$SinceWhenItemsTableTableManager(
        _db.attachedDatabase,
        _db.sinceWhenItems,
      );
  $$GlossaryItemsTableTableManager get glossaryItems =>
      $$GlossaryItemsTableTableManager(_db.attachedDatabase, _db.glossaryItems);
  $$TagItemsTableTableManager get tagItems =>
      $$TagItemsTableTableManager(_db.attachedDatabase, _db.tagItems);
}
