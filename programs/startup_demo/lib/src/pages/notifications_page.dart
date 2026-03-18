// lib/src/pages/notifications_page.dart

import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('2 unread', style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            _NotificationTile(
              icon: Icons.warning_amber_outlined,
              color: theme.colorScheme.errorContainer,
              title: 'System alert',
              body: 'Scheduled maintenance tonight at 11 PM.',
              time: '10:30 AM',
              unread: true,
            ),
            _NotificationTile(
              icon: Icons.person_outlined,
              color: theme.colorScheme.primaryContainer,
              title: 'Profile updated',
              body: 'Your profile details were saved successfully.',
              time: '9:45 AM',
              unread: true,
            ),
            _NotificationTile(
              icon: Icons.check_circle_outline,
              color: theme.colorScheme.secondaryContainer,
              title: 'Task completed',
              body: 'Onboarding checklist marked complete.',
              time: 'Yesterday',
              unread: false,
            ),
            _NotificationTile(
              icon: Icons.info_outline,
              color: theme.colorScheme.tertiaryContainer,
              title: 'Welcome',
              body: 'Thanks for joining. Get started below.',
              time: 'Jan 1',
              unread: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            unread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(time, style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
