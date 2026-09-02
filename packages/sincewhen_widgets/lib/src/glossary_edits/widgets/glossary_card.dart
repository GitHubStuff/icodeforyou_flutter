// packages/sincewhen_widgets/lib/src/glossary_edits/widgets/glossary_card.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sincewhen_models/sincewhen_models.dart';

const double _colorBoxSize = 48;
const _margin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const _padding = EdgeInsets.all(16);
final _border = BorderRadius.circular(12);

/// {@template glossary_card}
/// A card widget that displays a [GlossaryItem].
///
/// It features an outer 2dp border, tightly encloses its content vertically,
/// renders the [GlossaryItem.tag] and [GlossaryItem.descr] on the left side,
/// and displays a vertically centered square color swatch box with a 2dp border
/// on the right.
/// {@endtemplate}
class GlossaryCard extends StatelessWidget {
  /// {@macro glossary_card}
  const GlossaryCard({
    required this.item,
    super.key,
    this.onTap,
    this.colorBoxSize = _colorBoxSize,
    this.margin = _margin,
    this.padding = _padding,
  });

  /// The [GlossaryItem] domain entity to display.
  final GlossaryItem item;

  /// Optional callback invoked when the card is tapped.
  final VoidCallback? onTap;

  /// The dimension (width and height) of the right color swatch box.
  ///
  /// Defaults to `48.0`.
  final double colorBoxSize;

  /// The empty space that surrounds the outside of the card.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)`.
  final EdgeInsetsGeometry margin;

  /// The empty space that surrounds the card's inner content.
  ///
  /// Defaults to `EdgeInsets.all(16.0)`.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    return Card(
      margin: margin,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: _border,
        side: BorderSide(
          color: borderColor,
          width: 2, // 2dp border around the card
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centered vertically
            children: [
              // Left side: Tag (larger font) and Description (smaller font)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Hug content vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tag,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.descr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              // Right side: Color swatch box with 2dp border
              Container(
                width: colorBoxSize,
                height: colorBoxSize,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: 2, // 2dp border around the color swatch
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
