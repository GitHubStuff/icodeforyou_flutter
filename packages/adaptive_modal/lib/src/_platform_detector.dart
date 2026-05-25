// lib/src/_platform_detector.dart
// ---------------------------------------------------------------------------
// _platform_detector.dart — determines the current platform form factor.
//
// Single responsibility: answer one question — is the current context running
// on a phone, or on a larger surface (tablet, desktop, web)?
//
// All callers receive a [FormFactor] value.  No Flutter widget state is held
// here.  This class is stateless and every method is static.
// ---------------------------------------------------------------------------

// ignore_for_file: document_ignores, comment_references

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// FormFactor
// ---------------------------------------------------------------------------

/// Describes the display surface the app is currently running on.
///
/// [FormFactor.phone] triggers full-screen modal behaviour.
/// [FormFactor.large] triggers anchored, constrained modal behaviour.
enum FormFactor {
  /// A phone-sized display.  Modal fills the screen.
  phone,

  /// A tablet, desktop, or web display.  Modal is constrained and anchored.
  large,
}

// ---------------------------------------------------------------------------
// _PlatformDetector
// ---------------------------------------------------------------------------

/// Resolves the current [FormFactor] from a [BuildContext].
///
/// Detection strategy (in priority order):
///
/// 1. Web — always [FormFactor.large] regardless of screen size because web
///    browsers virtually never run in a true phone form factor in production.
///
/// 2. Physical platform — desktop platforms (macOS, Windows, Linux) are
///    always [FormFactor.large].
///
/// 3. Screen width — the remaining case covers iOS, Android, and Fuchsia.
///    A [MediaQuery] short-side width below [_phoneBreakpoint] is treated as
///    a phone.  This correctly handles iPads running the app in split-screen
///    at narrow widths by falling back to phone layout.
///
/// The breakpoint value of 600dp matches the Material Design guidance for the
/// phone/tablet boundary and is consistent with [AdaptiveLayout] from the
/// flutter_adaptive_scaffold package.
abstract final class PlatformDetector {
  /// The logical pixel width below which a device is considered a phone.
  static const double _phoneBreakpoint = 600;

  /// Returns the [FormFactor] for the given [context].
  ///
  /// Must be called from a widget that has a [MediaQuery] ancestor — i.e. any
  /// widget below a [MaterialApp] or [WidgetsApp].
  static FormFactor resolve(BuildContext context) {
    if (kIsWeb) return FormFactor.large;

    if (_isDesktopPlatform) return FormFactor.large;

    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return shortestSide < _phoneBreakpoint
        ? FormFactor.phone
        : FormFactor.large;
  }

  /// Returns true when running on macOS, Windows, or Linux.
  static bool get _isDesktopPlatform {
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Convenience accessor — true when [resolve] would return [FormFactor.phone]
  static bool isPhone(BuildContext context) =>
      resolve(context) == FormFactor.phone;

  /// Convenience accessor — true when [resolve] would return [FormFactor.large]
  static bool isLarge(BuildContext context) =>
      resolve(context) == FormFactor.large;
}

// ---------------------------------------------------------------------------
// _BreakpointObserver
// ---------------------------------------------------------------------------

/// Notifies listeners when the [FormFactor] changes during the widget
/// lifecycle — for example when the device rotates or a desktop window is
/// resized across the breakpoint boundary.
///
/// Attach to a [StatefulWidget] by calling [attach] in [didChangeDependencies]
/// and [dispose] in the widget's [dispose] method.
///
/// The [onChange] callback receives the new [FormFactor] whenever it differs
/// from the previously observed value.
final class BreakpointObserver {
  /// Constructor
  BreakpointObserver({required this.onChange});

  /// Called whenever the resolved [FormFactor] changes.
  final void Function(FormFactor formFactor) onChange;

  FormFactor? _last;

  /// Evaluates the current [FormFactor] and fires [onChange] if it has changed
  /// since the last call.
  ///
  /// Call this from [State.didChangeDependencies].
  void evaluate(BuildContext context) {
    final current = PlatformDetector.resolve(context);
    if (current == _last) return;
    _last = current;
    onChange(current);
  }

  /// Resets internal state.  Call from [State.dispose].
  void dispose() {
    _last = null;
  }
}

// ---------------------------------------------------------------------------
// _SafeAreaInsets
// ---------------------------------------------------------------------------

/// Provides safe area insets from [MediaQuery] with a fallback of zero.
///
/// Used by [_PositionResolver] when clamping the modal position to ensure
/// the modal never overlaps system UI (notch, home indicator, status bar).
abstract final class SafeAreaInsets {
  /// Returns the [EdgeInsets] representing the safe area for [context].
  static EdgeInsets of(BuildContext context) => MediaQuery.paddingOf(context);

  /// Returns the top safe area inset (status bar / notch height).
  static double top(BuildContext context) => of(context).top;

  /// Returns the bottom safe area inset (home indicator height).
  static double bottom(BuildContext context) => of(context).bottom;
}

// ---------------------------------------------------------------------------
// _ScreenSize
// ---------------------------------------------------------------------------

/// Provides the full logical screen size from [MediaQuery].
///
/// A thin wrapper that keeps [MediaQuery] access in one place so that
/// [_PositionResolver] and [_OverlayManager] never call [MediaQuery] directly.
abstract final class ScreenSize {
  /// Returns the full logical screen [Size] for [context].
  static Size of(BuildContext context) => MediaQuery.sizeOf(context);

  /// Returns the screen width in logical pixels.
  static double width(BuildContext context) => of(context).width;

  /// Returns the screen height in logical pixels.
  static double height(BuildContext context) => of(context).height;
}

// ---------------------------------------------------------------------------
// WindowSizeClass
// ---------------------------------------------------------------------------

/// Classifies the current window into a Material 3 window size class.
///
/// Used internally to make fine-grained layout decisions beyond the coarse
/// [FormFactor] split — for example, choosing how far from the anchor to
/// offset the modal on an extra-large display versus a compact tablet.
///
/// Breakpoints follow Material Design 3 adaptive layout guidance:
/// - Compact  : width < 600dp
/// - Medium   : 600dp ≤ width < 840dp
/// - Expanded : width ≥ 840dp
///
/// Reference: https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSizeClass {
  /// Width < 600dp.  Typical phone in portrait.
  compact,

  /// 600dp ≤ width < 840dp.  Typical phone in landscape or small tablet.
  medium,

  /// Width ≥ 840dp.  Tablet, desktop, or web.
  expanded,
}

/// Resolves the [WindowSizeClass] for a given [BuildContext].
abstract final class WindowSizeClassResolver {
  static const double _mediumBreakpoint = 600;
  static const double _expandedBreakpoint = 840;

  /// Returns the [WindowSizeClass] for the current window width.
  static WindowSizeClass resolve(BuildContext context) {
    final width = ScreenSize.width(context);
    if (width < _mediumBreakpoint) return WindowSizeClass.compact;
    if (width < _expandedBreakpoint) return WindowSizeClass.medium;
    return WindowSizeClass.expanded;
  }
}
