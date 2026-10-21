//

import 'package:flutter/material.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:spinners/spinners.dart' show PlatformSpinner;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const double _kMinSize = 16;
const double _kMaxSize = 240;
const double _kInitialSize = 64;
const double _kGallerySize = 72;
const double _kGallerySpacing = 24;

@UseCase(name: 'Interactive', type: PlatformSpinner)
Widget buildPlatformSpinnerInteractive(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: _kInitialSize,
    min: _kMinSize,
    max: _kMaxSize,
  );

  final color = context.knobs.colorOrNull(label: 'color');

  final osPlatform = context.knobs.objectOrNull.dropdown<OSPlatform>(
    label: 'osPlatform',
    options: OSPlatform.values,
    labelBuilder: (platform) => platform.name,
  );

  return PlatformSpinner(size: size, color: color, osPlatform: osPlatform);
}

@UseCase(name: 'Gallery', type: PlatformSpinner)
Widget buildPlatformSpinnerGallery(BuildContext context) {
  final color = context.knobs.colorOrNull(label: 'color');

  return Center(
    child: Wrap(
      spacing: _kGallerySpacing,
      runSpacing: _kGallerySpacing,
      alignment: WrapAlignment.center,
      children: [
        for (final platform in OSPlatform.values)
          _GalleryTile(platform: platform, color: color),
      ],
    ),
  );
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.platform, this.color});

  final OSPlatform platform;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlatformSpinner(
          size: _kGallerySize,
          color: color,
          osPlatform: platform,
        ),
        const SizedBox(height: 8),
        Text(platform.name, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
