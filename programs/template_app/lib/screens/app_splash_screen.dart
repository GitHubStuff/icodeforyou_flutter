// programs/template_app/lib/screens/app_splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _kBlack = Color(0xFF000000);
const Color _kTransparent = Color(0x00000000);

const double _kElevation = 0;
const double _kIconSize = 24;

const IconThemeData _kIconTheme = IconThemeData(
  color: _kBlack,
  size: _kIconSize,
);

const SystemUiOverlayStyle _kOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: _kBlack,
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: _kBlack,
  systemNavigationBarDividerColor: _kBlack,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarContrastEnforced: false,
);

const ColorScheme _kBlackColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _kBlack,
  onPrimary: _kBlack,
  primaryContainer: _kBlack,
  onPrimaryContainer: _kBlack,
  secondary: _kBlack,
  onSecondary: _kBlack,
  secondaryContainer: _kBlack,
  onSecondaryContainer: _kBlack,
  tertiary: _kBlack,
  onTertiary: _kBlack,
  tertiaryContainer: _kBlack,
  onTertiaryContainer: _kBlack,
  error: _kBlack,
  onError: _kBlack,
  errorContainer: _kBlack,
  onErrorContainer: _kBlack,
  surface: _kBlack,
  onSurface: _kBlack,
  surfaceTint: _kBlack,
  surfaceContainerLowest: _kBlack,
  surfaceContainerLow: _kBlack,
  surfaceContainer: _kBlack,
  surfaceContainerHigh: _kBlack,
  surfaceContainerHighest: _kBlack,
  outline: _kBlack,
  outlineVariant: _kBlack,
  shadow: _kBlack,
  scrim: _kBlack,
  inverseSurface: _kBlack,
  onInverseSurface: _kBlack,
  inversePrimary: _kBlack,
);

/// The first route shown after `MaterialApp` or `CupertinoApp` is built.
///
/// The screen carries no chrome: no app bar, no drawers, no bottom bars, no
/// buttons. It paints a single black surface that bleeds edge to edge, behind
/// the status bar and the system navigation bar, and stays black while the
/// keyboard opens or the device rotates.
///
/// [child] is the only thing on screen that is not black. It is centred and
/// rendered with the theme that was ambient where this widget was created, so
/// the black theme applied to the surface never reaches it.
class AppSplashScreen extends StatelessWidget {
  /// Creates a black splash surface that shows [child] and nothing else.
  const AppSplashScreen({required this.child, super.key});

  /// The only widget on the screen exempt from the black theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData ambientTheme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kOverlayStyle,
      child: Theme(
        data: _blackTheme(ambientTheme),
        child: ColoredBox(
          color: _kBlack,
          child: Scaffold(
            backgroundColor: _kBlack,
            primary: false,
            extendBody: true,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            drawerScrimColor: _kBlack,
            body: SizedBox.expand(
              child: Center(
                child: Theme(data: ambientTheme, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Derives an all-black [ThemeData] from [base].
///
/// Every colour the framework could paint on this screen resolves to black:
/// surfaces, scrims, overlays, dividers, icons, text, selection handles and
/// progress indicators. Typography metrics, density and platform behaviour are
/// inherited from [base] so the screen still honours the app configuration.
ThemeData _blackTheme(ThemeData base) {
  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: _kBlackColorScheme,
    scaffoldBackgroundColor: _kBlack,
    canvasColor: _kBlack,
    cardColor: _kBlack,
    dividerColor: _kBlack,
    disabledColor: _kBlack,
    focusColor: _kBlack,
    hoverColor: _kBlack,
    highlightColor: _kBlack,
    splashColor: _kBlack,
    shadowColor: _kBlack,
    primaryColor: _kBlack,
    primaryColorLight: _kBlack,
    primaryColorDark: _kBlack,
    secondaryHeaderColor: _kBlack,
    unselectedWidgetColor: _kBlack,
    hintColor: _kBlack,
    splashFactory: NoSplash.splashFactory,
    iconTheme: _kIconTheme,
    primaryIconTheme: _kIconTheme,
    textTheme: base.textTheme.apply(
      bodyColor: _kBlack,
      displayColor: _kBlack,
      decorationColor: _kBlack,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      bodyColor: _kBlack,
      displayColor: _kBlack,
      decorationColor: _kBlack,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _kBlack,
      selectionColor: _kTransparent,
      selectionHandleColor: _kBlack,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _kBlack,
      linearTrackColor: _kBlack,
      circularTrackColor: _kBlack,
      refreshBackgroundColor: _kBlack,
    ),
    dividerTheme: const DividerThemeData(color: _kBlack),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: _kBlack,
      dividerColor: _kBlack,
      labelColor: _kBlack,
      unselectedLabelColor: _kBlack,
      overlayColor: WidgetStatePropertyAll<Color>(_kTransparent),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _kBlack,
      foregroundColor: _kBlack,
      surfaceTintColor: _kBlack,
      shadowColor: _kBlack,
      elevation: _kElevation,
      scrolledUnderElevation: _kElevation,
      iconTheme: _kIconTheme,
      actionsIconTheme: _kIconTheme,
      systemOverlayStyle: _kOverlayStyle,
    ),
  );
}
