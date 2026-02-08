// lib/package/since_when/_shared_widgets.dart

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';

/// Status bar widget.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(status, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

/// Card displaying a SinceWhenRecord.
class RecordCard extends StatelessWidget {
  const RecordCard({
    super.key,
    required this.record,
    this.highlight = false,
    this.highlightTagNames = const {},
  });

  final SinceWhenRecord record;
  final bool highlight;
  final Set<String> highlightTagNames;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: highlight
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.metaData,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                CategoryChip(category: record.category),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.dataString,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (record.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: record.tags.map((tag) {
                  final isHighlighted = highlightTagNames.contains(tag.tagName);
                  return TagChip(tag: tag, highlighted: isHighlighted);
                }).toList(),
              ),
            const SizedBox(height: 8),
            Text(
              'Created: ${record.createdTimeStamp}',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
            ),
            if (record.parentTimeStamp != null)
              Text(
                'Parent: ${record.parentTimeStamp}',
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tag chip with color from TagDefinition.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag, this.highlighted = false});
  final TagDefinition tag;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: highlighted ? Color(tag.color) : Color(tag.color).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#${tag.tagName}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
          color: highlighted ? Colors.white : Color(tag.color),
        ),
      ),
    );
  }
}

/// Category chip.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Info card with title and children.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Label-value row.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

/// Code block.
class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
    );
  }
}
