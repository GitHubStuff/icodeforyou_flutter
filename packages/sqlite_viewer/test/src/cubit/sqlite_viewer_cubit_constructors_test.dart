// packages/sqlite_viewer/test/src/cubit/sqlite_viewer_cubit_constructors_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_cubit.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';

class _FakeSource extends Fake implements SqliteViewerAbstract {}

void main() {
  group('SqliteViewerCubit seeded constructors', () {
    late _FakeSource source;

    setUp(() {
      source = _FakeSource();
    });

    const seedMetadata = DatabaseMetadata(
      fullPath: '/tmp/test.db',
      sqliteVersion: '3.45.0',
      databaseSize: 1024,
      tables: ['users', 'posts'],
    );
    const seedState = MetadataLoaded(metadata: seedMetadata);

    test('SqliteViewerCubit.seeded emits the provided initial state', () {
      final cubit = SqliteViewerCubit.seeded(source, seedState);
      addTearDown(cubit.close);

      expect(cubit.state, same(seedState));
    });

    test('SqliteViewerCubit.withState emits the provided initial state', () {
      final cubit = SqliteViewerCubit.withState(source, seedState);
      addTearDown(cubit.close);

      expect(cubit.state, same(seedState));
    });
  });
}
