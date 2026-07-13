import 'dart:async';
import 'dart:ui' as ui;
import 'package:earth_spin/src/sprite_painter.dart' show SpritePainter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EarthSpin extends StatefulWidget {
  /// The name of the package containing the asset.
  /// Defaults to 'earth_rotator'.
  final String packageName;

  const EarthSpin({super.key, this.packageName = 'earth_spin'});

  @override
  State<EarthSpin> createState() => _EarthSpin();
}

class _EarthSpin extends State<EarthSpin> with SingleTickerProviderStateMixin {
  ui.Image? _spriteSheet;
  late AnimationController _controller;
  late Animation<int> _frameAnimation;

  // Grid dimensions from the file
  final int columns = 14;
  final int rows = 8;
  final int totalFrames = 96;

  @override
  void initState() {
    super.initState();
    _loadImage();

    // 14 seconds for a complete rotation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _frameAnimation = IntTween(
      begin: 0,
      end: totalFrames - 1,
    ).animate(_controller);
  }

  Future<void> _loadImage() async {
    try {
      // Prefixing with 'packages/package_name/' allows Flutter to resolve
      // the asset bundle context correctly when called from a host app.
      final String assetPath =
          'packages/${widget.packageName}/assets/rotated.png';

      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final ui.FrameInfo fi = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _spriteSheet = fi.image;
        });
      }
    } catch (e) {
      debugPrint('Error loading EarthRotator asset: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_spriteSheet == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    return AnimatedBuilder(
      animation: _frameAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            _spriteSheet!.width / columns,
            _spriteSheet!.height / rows,
          ),
          painter: SpritePainter(
            image: _spriteSheet!,
            currentFrame: _frameAnimation.value,
            columns: columns,
            rows: rows,
          ),
        );
      },
    );
  }
}
