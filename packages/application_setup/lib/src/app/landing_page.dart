// lib/src/app/landing_page.dart

import 'package:flutter/widgets.dart';

/// Wraps the caller's [app] widget as the post-splash destination.
class LandingPage extends StatelessWidget {
  const LandingPage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
