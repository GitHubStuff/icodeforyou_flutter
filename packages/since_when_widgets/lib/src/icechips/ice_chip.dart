// since_when_widgets/lib/src/icechips/ice_chip.dart

import 'package:extensions/extensions.dart'
    show ColorExtension, IntExt, StringExt;
import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart' show RecordTagDefinition;
import 'package:since_when_widgets/src/icechips/ice_chip_padding.dart'
    show IceChipPadding;

part '_size_config.dart';

const _kDefaultBorderWidth = 0.0;
const _kDefaultFontSize = 12.0;
const _kExpandedFontSize = 35.0;
const _kDefaultMinFontSize = 8.0;
const _kDefaultMaxLength = 7;
const _kTrailing = '…';
const _kMinLength = 1;
const _kWidestChar = 'M';

class IceChip extends StatelessWidget {
  const IceChip({
    required this.tagRecord,
    this.style = const TextStyle(fontSize: _kDefaultFontSize),
    this.borderWidth = _kDefaultBorderWidth,
    this.padding = IceChipPadding.normal,
    this.maxCharacters = _kDefaultMaxLength,
    super.key,
  }) : assert(borderWidth >= 0.0, 'borderWidth must be >= 0.0'),
       assert(
         maxCharacters >= _kMinLength,
         'maxCharacters must be >= $_kMinLength',
       );

  factory IceChip.standard(
    RecordTagDefinition tagRecord, {
    double borderWidth = _kDefaultBorderWidth,
    IceChipPadding padding = IceChipPadding.normal,
  }) {
    if (borderWidth < 0.0) {
      throw ArgumentError.value(
        borderWidth,
        'borderWidth',
        'must be >= 0.0',
      );
    }
    return IceChip(
      tagRecord: tagRecord,
      borderWidth: borderWidth,
      padding: padding,
    );
  }

  factory IceChip.expanded(
    RecordTagDefinition tagRecord, {
    BoxConstraints? constraints,
    FontWeight fontWeight = FontWeight.bold,
    double borderWidth = _kDefaultBorderWidth,
    IceChipPadding padding = IceChipPadding.normal,
    double minFontSize = _kDefaultMinFontSize,
  }) {
    if (borderWidth < 0.0) {
      throw ArgumentError.value(
        borderWidth,
        'borderWidth',
        'must be >= 0.0',
      );
    }
    if (minFontSize <= 0.0) {
      throw ArgumentError.value(
        minFontSize,
        'minFontSize',
        'must be > 0.0',
      );
    }

    final fontSize = constraints == null
        ? _kExpandedFontSize
        : _fitFontSize(
            _SizeConfig(
              text: tagRecord.tagName,
              maxWidth: constraints.maxWidth,
              fontWeight: fontWeight,
              padding: padding,
              minFontSize: minFontSize,
            ),
          );

    return IceChip(
      tagRecord: tagRecord,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      maxCharacters: tagRecord.tagName.length,
      borderWidth: borderWidth,
      padding: padding,
    );
  }

  static double _fitFontSize(_SizeConfig config) {
    var low = config.minFontSize;
    var high = _kExpandedFontSize;

    while (high - low > 0.5) {
      final mid = (low + high) / 2;
      final width = _measuredChipWidth(config.text, mid, config);
      if (width <= config.maxWidth) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return low;
  }

  static double _measuredChipWidth(
    String text,
    double fontSize,
    _SizeConfig config,
  ) {
    final size = text
        .padRight(_kMinLength, _kWidestChar)
        .renderSize(
          fontSize: fontSize,
          fontWeight: config.fontWeight,
        );
    return _chipWidthFromMetrics(size.width, size.height, config.padding);
  }

  static double _chipWidthFromMetrics(
    double textWidth,
    double textHeight,
    IceChipPadding padding,
  ) {
    final chipHeight = textHeight + (2 * padding.padding);
    final endCapRadius = chipHeight / 2;
    final horizontalPadding = endCapRadius + padding.padding;
    return textWidth + (2 * horizontalPadding);
  }

  final RecordTagDefinition tagRecord;

  /// A style suggestion. Text color is always computed from [tagRecord.color]
  /// for contrast. All other [TextStyle] properties are applied.
  final TextStyle style;

  final double borderWidth;
  final IceChipPadding padding;
  final int maxCharacters;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _effectiveStyle();
    final displayLabel = _displayLabel();
    final rendered = displayLabel
        .padRight(_kMinLength, _kWidestChar)
        .renderSize(
          fontSize: effectiveStyle.fontSize ?? _kDefaultFontSize,
          fontWeight: effectiveStyle.fontWeight ?? FontWeight.normal,
        );
    final chipSize = _chipSize(rendered.width, rendered.height);

    return SizedBox(
      width: chipSize.width,
      height: chipSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _background(),
          _label(displayLabel, effectiveStyle),
          if (borderWidth > 0.0) _border(context),
        ],
      ),
    );
  }

  Widget _background() => DecoratedBox(
    decoration: ShapeDecoration(
      color: tagRecord.color.toColor(),
      shape: const StadiumBorder(),
    ),
  );

  Widget _label(String displayLabel, TextStyle effectiveStyle) => Center(
    child: Text(
      displayLabel,
      style: effectiveStyle,
      maxLines: 1,
      overflow: TextOverflow.clip,
    ),
  );

  Widget _border(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      shape: StadiumBorder(
        side: BorderSide(
          color: _borderColor(context),
          width: borderWidth,
        ),
      ),
    ),
  );

  String _displayLabel() {
    final name = tagRecord.tagName;
    if (name.length <= maxCharacters) return name;
    return '${name.substring(0, maxCharacters - 1)}$_kTrailing';
  }

  Size _chipSize(double textWidth, double textHeight) {
    final chipHeight = textHeight + (2 * padding.padding);
    final chipWidth = IceChip._chipWidthFromMetrics(
      textWidth,
      textHeight,
      padding,
    );
    return Size(chipWidth, chipHeight);
  }

  TextStyle _effectiveStyle() => style.copyWith(
    color: tagRecord.color.toColor().contrastingTextColor(),
  );

  Color _borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
}
