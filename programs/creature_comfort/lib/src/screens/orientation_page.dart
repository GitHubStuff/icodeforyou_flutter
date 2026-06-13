// ignore_for_file: public_member_api_docs

import 'package:creature_comfort/src/typedef.dart' show defStyle;
import 'package:custom_widgets/custom_widgets.dart'
    show OrientationFlex, UninheritedText;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

class OrientationPage extends StatelessWidget {
  const OrientationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: OrientationFlex(
          spacing: 20,
          children: _kids,
        ),
      ),
    );
  }
}

final List<Widget> _kids = [
  OrientationFlex(children: _please),
  const Gap(12),
  OrientationFlex(children: _orRegister),
];

final List<Widget> _please = [
  const UninheritedText('Please'),
  const Gap(8),
  FilledButton(
    onPressed: () {},
    child: const Text('Login', style: defStyle),
  ),
];

final List<Widget> _orRegister = [
  const UninheritedText('- Or -'),
  const Gap(8),
  FilledButton(
    onPressed: () {},
    child: const Text('Register', style: defStyle),
  ),
];
