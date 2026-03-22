// since_when_widgets/lib/src/icechips/_size_config.dart

part of 'ice_chip.dart';

class _SizeConfig {
  const _SizeConfig({
    required this.text,
    required this.maxWidth,
    required this.fontWeight,
    required this.padding,
    required this.minFontSize,
  });

  final String text;
  final double maxWidth;
  final FontWeight fontWeight;
  final IceChipPadding padding;
  final double minFontSize;
}
