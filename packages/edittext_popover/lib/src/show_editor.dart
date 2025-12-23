// lib/src/show_editor.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '_constants.dart';
import '_editor_overlay.dart';
import 'editor_result.dart';

/// Shows the editor overlay and returns an [EditorResult] when closed.
///
/// On phones: displays as full-screen overlay below safe area.
/// On tablets/desktop/web: displays positioned near [targetRect] if provided.
///
/// Returns [EditorCompleted] when saved, [EditorDismissed] when cancelled.
Future<EditorResult> showEditor({
  required BuildContext context,
  String initialText = '',
  TextStyle? textStyle,
  Color? barrierColor,
  Widget? saveWidget,
  Widget? cancelWidget,
  Rect? targetRect,
  @visibleForTesting PlatformChecker? platformChecker,
}) async {
  final checker = platformChecker ?? const PlatformChecker();
  final isFullScreen = checker.shouldUseFullScreen(context);

  final effectiveTextStyle =
      textStyle ??
      const TextStyle(
        fontSize: kDefaultTextSize,
        fontFamily: '.SF UI Text',
      );

  final effectiveBarrierColor =
      barrierColor ?? Colors.black.withValues(alpha: kBarrierOpacity);

  final effectiveSaveWidget =
      saveWidget ??
      const Text(
        'SAVE',
        style: TextStyle(
          fontSize: kDefaultButtonTextSize,
          fontWeight: FontWeight.w600,
        ),
      );

  final effectiveCancelWidget =
      cancelWidget ??
      const Text(
        'CANCEL',
        style: TextStyle(
          fontSize: kDefaultButtonTextSize,
          fontWeight: FontWeight.w600,
        ),
      );

  final result = await Navigator.of(context).push<EditorResult>(
    PageRouteBuilder<EditorResult>(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditorOverlay(
          initialText: initialText,
          textStyle: effectiveTextStyle,
          barrierColor: effectiveBarrierColor,
          saveWidget: effectiveSaveWidget,
          cancelWidget: effectiveCancelWidget,
          targetRect: targetRect,
          isFullScreen: isFullScreen,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );

  return result ?? EditorDismissed(text: initialText);
}

/// Checks platform to determine editor display mode.
@visibleForTesting
class PlatformChecker {
  const PlatformChecker();

  static const double phoneBreakpoint = 600.0;

  bool get isWeb => kIsWeb;

  bool get isMobile => Platform.isIOS || Platform.isAndroid;

  bool shouldUseFullScreen(BuildContext context) {
    if (isWeb) {
      final size = MediaQuery.sizeOf(context);
      return size.width < phoneBreakpoint;
    }

    if (isMobile) {
      final size = MediaQuery.sizeOf(context);
      return size.shortestSide < phoneBreakpoint;
    }

    return false;
  }
}
