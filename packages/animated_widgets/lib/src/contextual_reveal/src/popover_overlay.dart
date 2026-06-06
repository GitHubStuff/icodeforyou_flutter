// animated_widgets/lib/src/contextual_reveal/popover_overlay.dart

part of 'contextual_reveal.dart';

class _PopoverOverlay {
  _PopoverOverlay({
    required Widget child,
    required this.parentKey,
    required this.opacity,
    required this.theme,
  }) : _child = child;

  final GlobalKey parentKey;
  final Animation<double> opacity;
  final ContextualRevealTheme theme;

  Widget _child;
  bool _interactive = false;
  VoidCallback? _onDismissRegionTap;
  final GlobalKey _contentKey = GlobalKey();
  OverlayEntry? _entry;

  bool get isVisible => _entry != null;

  // ignore: avoid_setters_without_getters, ignore: document_ignores
  set child(Widget value) {
    _child = value;
    _entry?.markNeedsBuild();
  }

  void insertNonInteractive(BuildContext context, {VoidCallback? onTap}) {
    _interactive = false;
    _onDismissRegionTap = onTap;
    _insert(context);
  }

  void insertInteractive(
    BuildContext context, {
    required VoidCallback onDismiss,
  }) {
    _interactive = true;
    _onDismissRegionTap = onDismiss;
    _insert(context);
  }

  void _insert(BuildContext context) {
    if (_entry != null) return; // coverage:ignore-line
    final parentRect = _rectFromKey(parentKey);
    if (parentRect == null) return; // coverage:ignore-line
    _entry = _buildEntry(parentRect, MediaQuery.sizeOf(context));
    Overlay.of(context).insert(_entry!);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _entry?.markNeedsBuild(),
    );
  }

  void remove() {
    _entry?.remove();
    _entry = null;
  }

  Rect? _rectFromKey(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null; // coverage:ignore-line
    return box.localToGlobal(Offset.zero) & box.size;
  }

  OverlayEntry _buildEntry(Rect parentRect, Size screenSize) => OverlayEntry(
    builder: (_) {
      final contentRect = _rectFromKey(_contentKey);
      final contentHeight = contentRect?.height ?? 0.0;
      final contentWidth = contentRect?.width ?? 0.0;

      final spaceAbove = parentRect.top - theme.popoverGap;
      final prefersAbove = spaceAbove >= contentHeight;

      final top = prefersAbove
          ? parentRect.top - contentHeight - theme.popoverGap
          : parentRect.bottom + theme.popoverGap;

      final left = parentRect.left.clamp(
        0.0,
        (screenSize.width - contentWidth).clamp(0.0, double.infinity),
      );

      return Stack(
        children: [
          if (_interactive)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onDismissRegionTap,
              ),
            ),
          Positioned(
            top: top,
            left: left,
            child: FadeTransition(
              opacity: opacity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _interactive ? () {} : _onDismissRegionTap,
                child: Material(
                  key: _contentKey,
                  color: theme.popoverBackgroundShade,
                  child: _child,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
