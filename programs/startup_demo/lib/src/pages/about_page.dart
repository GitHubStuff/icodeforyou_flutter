// lib/src/pages/about_page.dart

import 'package:animated_widgets/animated_widgets.dart' show ContextualReveal;
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:random_color_generator/random_color_generator.dart'
    show RandomColorGenerator;
import 'package:since_when/since_when.dart';
import 'package:since_when_widgets/since_when_widgets.dart' show IceChip;

final tag01 = RecordTagDefinition(
  createdTimeStamp: 0x0000,
  tagName: 'Tag 01',
  color: RandomColorGenerator.generate().toInt(),
);

final tag02 = RecordTagDefinition(
  createdTimeStamp: 0x0000,
  tagName: 'Tag 02',
  color: RandomColorGenerator.generate().toInt(),
);

final tag03 = RecordTagDefinition(
  createdTimeStamp: 0x0000,
  tagName: 'This is Tag3',
  color: RandomColorGenerator.generate().toInt(),
);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: theme.textTheme.headlineMedium),
            const Gap(24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const Gap(16),
            Center(
              child: Text('Startup Demo', style: theme.textTheme.titleLarge),
            ),
            Center(
              child: Text('Version 1.0.0', style: theme.textTheme.bodySmall),
            ),
            const SizedBox(height: 32),
            const _AboutRow(label: 'Built with', value: 'Flutter'),
            const _AboutRow(label: 'Navigation', value: 'animated_rail_menu'),
            const _AboutRow(label: 'State', value: 'flutter_bloc'),
            const _AboutRow(label: 'DI', value: 'get_it'),
            const Gap(4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ContextualReveal(
                  parent: IceChip.standard(tag01),
                  longChild: IceChip.expanded(tag01),
                  doubleChild: IceChip.expanded(tag01),
                  doublePosition: .popover,
                  child: IceChip.expanded(tag01),
                ),
                ContextualReveal(
                  parent: IceChip.standard(tag02),
                  longChild: IceChip.expanded(tag02),
                  doubleChild: Column(
                    children: [
                      IceChip.standard(tag01),
                      const Gap(10),
                      IceChip.expanded(tag03),
                    ],
                  ),
                  doublePosition: .modal,
                  child: IceChip.expanded(tag01),
                ),
                ContextualReveal(
                  parent: IceChip.standard(tag03),
                  longChild: IceChip.expanded(tag03),
                  doubleChild: IceChip.expanded(tag03),
                  doublePosition: .bottomSheet,
                  child: IceChip.expanded(tag03),
                ),
                ContextualReveal(
                  parent: IceChip.standard(tag02),
                  longChild: IceChip.expanded(tag02),
                  doubleChild: IceChip.expanded(tag02),
                  doublePosition: .push,
                  child: IceChip.expanded(tag02),
                ),
                ContextualReveal(
                  parent: const Text(
                    "Now I'm cooking",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.pink,
                    ),
                  ),
                  longChild: IceChip.expanded(tag02),
                  doubleChild: IceChip.expanded(tag03),
                  doublePosition: .popover,
                  child: IceChip.expanded(tag01),
                ),
              ],
            ),

            Center(
              child: Text(
                '© 2026 LTMM LLC, All rights reserved.',
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
