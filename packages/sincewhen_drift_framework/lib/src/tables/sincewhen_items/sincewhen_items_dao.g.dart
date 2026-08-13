// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sincewhen_items_dao.dart';

// ignore_for_file: type=lint
mixin _$SinceWhenItemsDaoMixin on DatabaseAccessor<SinceWhenDatabase> {
  $SinceWhenItemsTable get sinceWhenItems => attachedDatabase.sinceWhenItems;
  SinceWhenItemsDaoManager get managers => SinceWhenItemsDaoManager(this);
}

class SinceWhenItemsDaoManager {
  final _$SinceWhenItemsDaoMixin _db;
  SinceWhenItemsDaoManager(this._db);
  $$SinceWhenItemsTableTableManager get sinceWhenItems =>
      $$SinceWhenItemsTableTableManager(
        _db.attachedDatabase,
        _db.sinceWhenItems,
      );
}
