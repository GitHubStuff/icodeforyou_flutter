// packages/archetypes/test/src/archetypes_test.dart

import 'package:archetypes/archetypes.dart';
import 'package:test/test.dart';

void main() {
  group(ArcheTypes, () {
    test('can be instantiated', () {
      expect(ArcheTypes(), isNotNull);
    });
  });
}
