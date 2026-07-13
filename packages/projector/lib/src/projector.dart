import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:projector/src/projector_painter.dart' show ProjectorPainter;

typedef ProjectorCycleCompleted = void Function();

class Projector extends StatefulWidget {
  const Projector({
    required this.image,
    required this.columns,
    required this.rows,
    required this.totalFrames,
    required this.controller,
    this.onCycleCompleted,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.loadingBuilder,
    this.errorBuilder,
    super.key,
  }) : assert(columns > 0, 'columns must be greater than zero'),
       assert(rows > 0, 'rows must be greater than zero'),
       assert(totalFrames > 0, 'totalFrames must be greater than zero'),
       assert(
         totalFrames <= columns * rows,
         'totalFrames cannot exceed columns × rows',
       );

  /// The sprite-sheet image.
  ///
  /// Examples:
  ///
  /// AssetImage:
  /// ```dart
  /// const AssetImage('assets/rotated.png')
  /// ```
  ///
  /// Package asset:
  /// ```dart
  /// const AssetImage(
  ///   'assets/rotated.png',
  ///   package: 'earth_spin',
  /// )
  /// ```
  final ImageProvider image;

  /// Number of horizontal frames in the sprite sheet.
  final int columns;

  /// Number of vertical frames in the sprite sheet.
  final int rows;

  /// Number of frames that should be displayed.
  ///
  /// This may be less than [columns] × [rows] when the final row is only
  /// partially populated.
  final int totalFrames;

  /// Animation controller owned and managed by the parent widget.
  ///
  /// Projector does not start, stop, repeat, or dispose this controller.
  final AnimationController controller;

  /// Called after the final frame has been displayed.
  ///
  /// For a repeating controller, this callback is invoked immediately before
  /// the animation wraps from its ending value back to its beginning value.
  final ProjectorCycleCompleted? onCycleCompleted;

  /// How the current frame should be inscribed into the available space.
  final BoxFit fit;

  /// How the current frame should be aligned within the available space.
  final Alignment alignment;

  /// Image sampling quality.
  final FilterQuality filterQuality;

  /// Optional widget displayed while the sprite sheet is loading.
  final WidgetBuilder? loadingBuilder;

  /// Optional widget displayed when the sprite sheet cannot be loaded.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;

  @override
  State<Projector> createState() => _ProjectorState();
}

class _ProjectorState extends State<Projector> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  ui.Image? _spriteSheet;
  Object? _imageError;
  StackTrace? _imageStackTrace;

  double _previousControllerValue = 0.0;
  int _currentFrame = 0;

  bool _finalFrameWasDisplayed = false;
  bool _completionReportedForCurrentCycle = false;

  @override
  void initState() {
    super.initState();

    _previousControllerValue = widget.controller.value;
    _currentFrame = _frameForValue(widget.controller.value);

    widget.controller.addListener(_handleControllerTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _resolveImage();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_imageStream == null) {
      _resolveImage();
    }
  }

  @override
  void didUpdateWidget(covariant Projector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerTick);

      _previousControllerValue = widget.controller.value;
      _currentFrame = _frameForValue(widget.controller.value);
      _finalFrameWasDisplayed = _currentFrame == widget.totalFrames - 1;
      _completionReportedForCurrentCycle = false;

      widget.controller.addListener(_handleControllerTick);
    }

    if (oldWidget.image != widget.image) {
      _resolveImage();
    }

    if (oldWidget.columns != widget.columns ||
        oldWidget.rows != widget.rows ||
        oldWidget.totalFrames != widget.totalFrames) {
      _currentFrame = _frameForValue(widget.controller.value);
      _finalFrameWasDisplayed = _currentFrame == widget.totalFrames - 1;
      _completionReportedForCurrentCycle = false;
    }
  }

  int _frameForValue(double controllerValue) {
    if (widget.totalFrames == 1) {
      return 0;
    }

    final double normalizedValue = controllerValue.clamp(0.0, 1.0);

    return (normalizedValue * widget.totalFrames).floor().clamp(
      0,
      widget.totalFrames - 1,
    );
  }

  void _handleControllerTick() {
    final double currentControllerValue = widget.controller.value;
    final int nextFrame = _frameForValue(currentControllerValue);

    final bool wrappedForward =
        currentControllerValue < _previousControllerValue &&
        _previousControllerValue >= 0.999;

    if (wrappedForward) {
      _reportCompletedCycle();
      _completionReportedForCurrentCycle = false;
      _finalFrameWasDisplayed = false;
    }

    if (nextFrame == widget.totalFrames - 1) {
      _finalFrameWasDisplayed = true;
    }

    final bool reachedCompletedValue =
        currentControllerValue >= 1.0 && _previousControllerValue < 1.0;

    if (reachedCompletedValue) {
      _reportCompletedCycle();
    }

    _previousControllerValue = currentControllerValue;

    if (nextFrame != _currentFrame && mounted) {
      setState(() {
        _currentFrame = nextFrame;
      });
    }
  }

  void _reportCompletedCycle() {
    if (!_finalFrameWasDisplayed || _completionReportedForCurrentCycle) {
      return;
    }

    _completionReportedForCurrentCycle = true;
    widget.onCycleCompleted?.call();
  }

  void _resolveImage() {
    final ImageStream newImageStream = widget.image.resolve(
      createLocalImageConfiguration(context),
    );

    if (_imageStream?.key == newImageStream.key) {
      return;
    }

    _removeImageStreamListener();

    setState(() {
      _spriteSheet = null;
      _imageError = null;
      _imageStackTrace = null;
    });

    _imageStream = newImageStream;

    _imageStreamListener = ImageStreamListener(
      _handleImageLoaded,
      onError: _handleImageError,
    );

    _imageStream!.addListener(_imageStreamListener!);
  }

  void _handleImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    if (!mounted) {
      return;
    }

    setState(() {
      _spriteSheet = imageInfo.image;
      _imageError = null;
      _imageStackTrace = null;
    });
  }

  void _handleImageError(Object error, StackTrace? stackTrace) {
    if (!mounted) {
      return;
    }

    setState(() {
      _spriteSheet = null;
      _imageError = error;
      _imageStackTrace = stackTrace;
    });
  }

  void _removeImageStreamListener() {
    final ImageStream? imageStream = _imageStream;
    final ImageStreamListener? listener = _imageStreamListener;

    if (imageStream != null && listener != null) {
      imageStream.removeListener(listener);
    }

    _imageStream = null;
    _imageStreamListener = null;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerTick);
    _removeImageStreamListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Object? imageError = _imageError;

    if (imageError != null) {
      return widget.errorBuilder?.call(context, imageError, _imageStackTrace) ??
          const Center(child: Icon(Icons.broken_image_outlined, size: 48));
    }

    final ui.Image? spriteSheet = _spriteSheet;

    if (spriteSheet == null) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    final double frameWidth = spriteSheet.width.toDouble() / widget.columns;
    final double frameHeight = spriteSheet.height.toDouble() / widget.rows;

    return AspectRatio(
      aspectRatio: frameWidth / frameHeight,
      child: CustomPaint(
        painter: ProjectorPainter(
          image: spriteSheet,
          currentFrame: _currentFrame,
          columns: widget.columns,
          rows: widget.rows,
          fit: widget.fit,
          alignment: widget.alignment,
          filterQuality: widget.filterQuality,
        ),
      ),
    );
  }
}
