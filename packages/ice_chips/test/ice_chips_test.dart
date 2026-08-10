// packages/ice_chips/test/ice_chips_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/ice_chips.dart';

/// Smoke tests proving every symbol exported by the `ice_chips` barrel
/// resolves through the barrel import alone.
void main() {
  group('ice_chips barrel', () {
    test('exports the glossary placeholder types', () {
      expect(GlossaryDeleter, isNotNull);
      expect(GlossaryReader, isNotNull);
      expect(GlossaryRepository, isNotNull);
      expect(GlossaryWriter, isNotNull);
      expect(RecordTagDefinition, isNotNull);
      expect(SinceWhenFailure, isNotNull);
    });

    test('exports the tray, layout, and picker widgets', () {
      expect(IceChipsTray, isNotNull);
      expect(IceChipsTrayCubit, isNotNull);
      expect(IceChipsTrayLayout, isNotNull);
      expect(IceChipsTrayLayoutWrap, isNotNull);
      expect(IceChipsTrayLayoutList, isNotNull);
      expect(IceChipsTrayLayoutRow, isNotNull);
      expect(IcePickerTray, isNotNull);
    });

    test('exports the chip widget, DTO, and tags state machine', () {
      expect(IceChip, isNotNull);
      expect(IceChipData, isNotNull);
      expect(TagsCubit, isNotNull);
      expect(const TagsInitial(), isA<TagsState>());
      expect(const TagsLoading(), isA<TagsState>());
    });
  });
}
