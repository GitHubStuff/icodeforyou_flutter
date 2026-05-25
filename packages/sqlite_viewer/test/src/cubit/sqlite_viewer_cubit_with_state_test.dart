// packages/sqlite_viewer/test/src/cubit/sqlite_viewer_cubit_with_state_test.dart

// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_cubit.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';

import '../../helpers/mock_sqlite_viewer_source.dart' show MockSqliteViewerSource;


void main() {
  const testMetadata = DatabaseMetadata(
    fullPath: '/test/path/database.db',
    sqliteVersion: '3.39.0',
    databaseSize: 4096,
    tables: ['users', 'posts'],
  );

  group('SqliteViewerCubit.withState', () {
    test('initialises with the provided state', () {
      final source = MockSqliteViewerSource();
      final cubit = SqliteViewerCubit.withState(
        source,
        MetadataLoaded(metadata: testMetadata),
      );

      expect(cubit.state, MetadataLoaded(metadata: testMetadata));

      unawaited(cubit.close());
    });
  });
}
