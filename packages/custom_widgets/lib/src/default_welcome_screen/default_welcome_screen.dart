import 'package:analog_clock_widget/analog_clock_widget.dart'
    show AnalogClock, ClockStyle;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:google_fonts/google_fonts.dart';
import 'package:three_d_sphere/three_d_sphere.dart' show ThreeDSphere;

/// Horizontal gap between the clock and the welcome text.
const _kSpacing = 16.0;

/// Font size for the welcome text, proportioned against the 100x100 clock.
const _kWelcomeFontSize = 24.0;

/// Deep purple screen background.
const MaterialColor _kBackgroundColor = Colors.deepPurple;

/// Welcome text foreground color.
const Color _kTextColor = Colors.white;

/// A full-screen welcome surface showing the analog clock beside a
/// 'Welcome' label, centered on a deep purple background.
class DefaultWelcomeScreen extends StatelessWidget {
  /// Creates a [DefaultWelcomeScreen].
  const DefaultWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kBackgroundColor,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnalogClock(
              radius: 75,
              style: const ClockStyle(
                hourHandColor: _kBackgroundColor,
                minuteHandColor: _kBackgroundColor,
              ),
            ),
            const Gap(_kSpacing),
            Text(
              'Welcome',
              style: GoogleFonts.archivoBlack(
                color: _kTextColor,
                fontSize: _kWelcomeFontSize,
              ),
            ),
            const Gap(_kSpacing),
            ThreeDSphere(
              width: 24,
              height: 24,
              color: Colors.amber[900]!,
            ),
          ],
        ),
      ),
    );
  }
}
