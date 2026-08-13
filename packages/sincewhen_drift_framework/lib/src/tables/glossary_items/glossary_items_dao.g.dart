// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glossary_items_dao.dart';

// ignore_for_file: type=lint
mixin _$GlossaryItemsDaoMixin on DatabaseAccessor<SinceWhenDatabase> {
  $GlossaryItemsTable get glossaryItems => attachedDatabase.glossaryItems;
  GlossaryItemsDaoManager get managers => GlossaryItemsDaoManager(this);
}

class GlossaryItemsDaoManager {
  final _$GlossaryItemsDaoMixin _db;
  GlossaryItemsDaoManager(this._db);
  $$GlossaryItemsTableTableManager get glossaryItems =>
      $$GlossaryItemsTableTableManager(_db.attachedDatabase, _db.glossaryItems);
}
