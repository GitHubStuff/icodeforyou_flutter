// packages/place_holder_widget/lib/src/place_holder_widget.dart

import 'package:flutter/widgets.dart';
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
class PlaceHolderWidget extends StatelessWidget {
  /// Creates a [PlaceHolderWidget].
  const PlaceHolderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Assets.placeholder512x512.image(
        // Constrains in-memory decode size (in physical pixels)
        cacheWidth: 256,
        cacheHeight: 256,
        fit: BoxFit.contain,
      ),
    );
  }
}
