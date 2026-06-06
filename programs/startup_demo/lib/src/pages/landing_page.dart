// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart'
    show  GrowWidgetView;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:remind_me/remind_me.dart' show RemindMe;

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final canSchedule = await RemindMe.instance
                    .canScheduleExactAlarms();
                if (!context.mounted) return;
                if (!canSchedule) {
                  final userAgreed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Permission needed'),
                      content: const Text(
                        'To remind you at the exact time you set, this app '
                        'needs permission to schedule alarms. '
                        'Tap "Open settings" and enable "Alarms & reminders".',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Open settings'),
                        ),
                      ],
                    ),
                  );
                  if (userAgreed != true) return;
                  await RemindMe.instance.requestExactAlarmsPermission();
                  return;
                }

                await RemindMe.instance.scheduleInMinutes(
                  title: 'Reminder',
                  body: '1-minute test reminder.',
                  duration: const Duration(minutes: 1),
                );
              },
              child: const Text('Remind me in 1 min'),
            ),
            Text('Welcome', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Here is a summary of your day.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Tasks',
                    value: '4',
                    icon: Icons.check_circle_outline,
                    color: theme.colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Alerts',
                    value: '2',
                    icon: Icons.notifications_outlined,
                    color: theme.colorScheme.secondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Events',
                    value: '1',
                    icon: Icons.calendar_month_outlined,
                    color: theme.colorScheme.tertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent Activity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const _ActivityTile(label: 'Completed onboarding', time: '9:00 AM'),
            const _ActivityTile(label: 'Profile updated', time: '9:45 AM'),
            const _ActivityTile(label: 'New alert received', time: '10:30 AM'),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(time, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
