// packages/place_holder_widget/lib/src/place_holder_widget.dart

import 'package:ext_widget/ext_widget.dart' show ExtWidget;
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:place_holder_widget/gen/assets.gen.dart';

/// A widget that displays a centered placeholder image.
///
/// This widget renders [Assets.placeholder512x512] centered within its parent
/// container. The image is scaled using [BoxFit.contain] and decoded at a
/// constrained resolution of 256×256 pixels via [Image.cacheWidth] and
/// [Image.cacheHeight] to reduce in-memory footprint.
///
/// Typically used as a visual fallback while content is loading or when an
/// image asset is unavailable or just a placeholder widget.
class PlaceholderWidget extends StatelessWidget {
  /// Creates a [PlaceholderWidget].
  const PlaceholderWidget({super.key, this.header, this.body});

  /// Optional header above the placeholder image
  final Widget? header;

  /// Widget that makes up the body of the display, with a default of
  /// 'Under Construction' widget in the packages /assets
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _column(),
    ).withSymmetricPadding(horizontal: 8);
  }

  Widget _column() => (header == null)
      ? _asset()
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            header!,
            const Gap(8),
            _asset(),
          ],
        );

  Widget _asset() =>
      header ??
      Assets.placeholder512x512.image(
        // Constrains in-memory decode size (in physical pixels)
        cacheWidth: 256,
        cacheHeight: 256,
        fit: BoxFit.contain,
      );
}
