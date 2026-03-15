// lib/src/counted_text_field/_counted_text_field_overlays.dart

part of 'counted_text_field.dart';

extension _Overlays on _CountedTextFieldState {
  Widget _buildBadge(
    BuildContext context,
    Color borderColor, {
    required bool isRtl,
  }) {
    final theme = Theme.of(context);
    final badgeStyle = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(
          color: borderColor,
          fontWeight: FontWeight.w600,
        );

    return Positioned(
      top: -7,
      right: isRtl ? null : 12,
      left: isRtl ? 12 : null,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text('$_count/${widget.maxLength}', style: badgeStyle),
      ),
    );
  }

  Widget _buildCaption(BuildContext context, {required bool isRtl}) {
    final theme = Theme.of(context);
    final captionStyle = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(
          color: widget.borderColor,
          fontWeight: FontWeight.w600,
        );

    return Positioned(
      top: -7,
      left: isRtl ? null : 12,
      right: isRtl ? 12 : null,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(widget.caption!, style: captionStyle),
      ),
    );
  }

  Widget _buildFloatingMessage(BuildContext context, {required bool isRtl}) {
    final theme = Theme.of(context);
    final messageStyle = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(
          color: widget.errorBorderColor,
          fontWeight: FontWeight.w600,
        );

    return Positioned(
      top: -28,
      right: isRtl ? null : 0,
      left: isRtl ? 0 : null,
      child: AnimatedOpacity(
        opacity: _messageOpacity,
        duration: Duration(milliseconds: widget.fadeMs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '🛑 Max ${widget.maxLength} characters',
            style: messageStyle,
          ),
        ),
      ),
    );
  }
}
