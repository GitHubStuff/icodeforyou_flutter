// lib/src/pages/help_page.dart

// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Frequently asked questions.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            const _FaqTile(
              question: 'How do I update my profile?',
              answer:
                  'Navigate to the Profile page and tap any field to edit it.',
            ),
            const _FaqTile(
              question: 'How do I change the app theme?',
              answer:
                  'Go to Settings and use the theme selector to switch between light and dark mode.',
            ),
            const _FaqTile(
              question: 'Where can I see my activity?',
              answer:
                  'The Analytics page shows a summary of your sessions and usage over the last 7 days.',
            ),
            const _FaqTile(
              question: 'How do I contact support?',
              answer:
                  'Email support@example.com or use the feedback button below.',
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Send Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(widget.answer, style: theme.textTheme.bodySmall),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
