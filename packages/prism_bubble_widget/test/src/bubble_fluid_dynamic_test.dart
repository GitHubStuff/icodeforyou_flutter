// packages/prism_bubble_widget/test/src/bubble_fluid_dynamic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart'
    show BubbleFluidDynamicEnum;

void main() {
  group('BubbleFluidDynamicEnum', () {
    test('contains all expected enum values in order', () {
      expect(
        BubbleFluidDynamicEnum.values,
        equals([
          BubbleFluidDynamicEnum.serene,
          BubbleFluidDynamicEnum.restless,
          BubbleFluidDynamicEnum.meditative,
          BubbleFluidDynamicEnum.frenetic,
          BubbleFluidDynamicEnum.molten,
          BubbleFluidDynamicEnum.tidal,
          BubbleFluidDynamicEnum.maelstrom,
          BubbleFluidDynamicEnum.dormant,
        ]),
      );
    });

    test('verifies enum values and names', () {
      expect(BubbleFluidDynamicEnum.serene.name, equals('serene'));
      expect(BubbleFluidDynamicEnum.restless.name, equals('restless'));
      expect(BubbleFluidDynamicEnum.meditative.name, equals('meditative'));
      expect(BubbleFluidDynamicEnum.frenetic.name, equals('frenetic'));
      expect(BubbleFluidDynamicEnum.molten.name, equals('molten'));
      expect(BubbleFluidDynamicEnum.tidal.name, equals('tidal'));
      expect(BubbleFluidDynamicEnum.maelstrom.name, equals('maelstrom'));
      expect(BubbleFluidDynamicEnum.dormant.name, equals('dormant'));
    });
  });
}
