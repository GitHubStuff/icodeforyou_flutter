// lib/src/app/landing_page.dart

import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}
