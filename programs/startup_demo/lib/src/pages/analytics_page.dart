// lib/src/pages/analytics_page.dart

import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Last 7 days', style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Sessions',
                    value: '1,240',
                    delta: '+12%',
                    positive: true,
                    color: theme.colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Errors',
                    value: '3',
                    delta: '-40%',
                    positive: true,
                    color: theme.colorScheme.secondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Avg Duration',
                    value: '4m 12s',
                    delta: '+5%',
                    positive: true,
                    color: theme.colorScheme.tertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Crashes',
                    value: '0',
                    delta: '—',
                    positive: true,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Top Pages', style: theme.textTheme.titleMedium),
            const Divider(),
            const _RankRow(rank: '1', label: 'Landing', visits: '540'),
            const _RankRow(rank: '2', label: 'Analytics', visits: '310'),
            const _RankRow(rank: '3', label: 'Profile', visits: '220'),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
    required this.color,
  });

  final String label;
  final String value;
  final String delta;
  final bool positive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            delta,
            style: theme.textTheme.labelSmall?.copyWith(
              color: positive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.label,
    required this.visits,
  });

  final String rank;
  final String label;
  final String visits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(rank, style: theme.textTheme.labelSmall),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text('$visits visits', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
