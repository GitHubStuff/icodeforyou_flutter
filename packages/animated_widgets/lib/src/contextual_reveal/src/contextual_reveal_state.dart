// animated_widgets/lib/src/contextual_reveal/contextual_reveal_state.dart

part of 'contextual_reveal.dart';

const _kBottomSheetBottomPadding = 48.0;

class _ContextualRevealState extends State<ContextualReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final GlobalKey _parentKey;
  late _PopoverOverlay _popover;
  Timer? _tapTimer;

  @override
  void initState() {
    super.initState();
    _parentKey = GlobalKey();
    _controller = AnimationController(vsync: this);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _popover = _PopoverOverlay(
      child: widget.tapChild,
      parentKey: _parentKey,
      opacity: _opacity,
      theme: ContextualRevealTheme.of(context),
    );
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _popover.remove();
    _controller.dispose();
    super.dispose();
  }

  // --- tap / click ---

  void _onTap() {
    if (_popover.isVisible) return;
    _popover
      ..child = widget.tapChild
      ..insertNonInteractive(context);
    final theme = ContextualRevealTheme.of(context);
    _fadeIn(theme.fadeInDuration);
    _tapTimer = Timer(theme.showDuration, () => _fadeOut(_popover.remove));
  }

  // --- long press / click hold ---

  void _onLongPressStart() {
    _popover
      ..child = widget.longChild
      ..insertNonInteractive(context);
    _fadeIn(ContextualRevealTheme.of(context).fadeInDuration);
  }

  void _onLongPressEnd() => _fadeOut(_popover.remove);

  // --- double tap / double click ---

  void _onDoubleTap() {
    switch (widget.doublePosition) {
      case ContextualPosition.popover:
        _showDoublePopover();
      case ContextualPosition.modal:
        _showDoubleModal();
      case ContextualPosition.bottomSheet:
        _showDoubleBottomSheet();
      case ContextualPosition.push:
        _showDoublePush();
    }
  }

  void _showDoublePopover() {
    _popover
      ..child = _DismissWrapper(
        child: widget.doubleChild,
        onDismiss: () => _fadeOut(_popover.remove),
      )
      ..insertInteractive(
        context,
        onDismiss: () => _fadeOut(_popover.remove),
      );
    _fadeIn(ContextualRevealTheme.of(context).fadeInDuration);
  }

  void _showDoubleModal() {
    final theme = ContextualRevealTheme.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: theme.barrierColor,
        builder: (dialogContext) => Stack(
          children: [
            Center(
              child: IntrinsicWidth(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      widget.doubleChild,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoubleBottomSheet() {
    final theme = ContextualRevealTheme.of(context);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: theme.popoverBackgroundShade,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: _kBottomSheetBottomPadding),
            child: _DismissWrapper(
              child: widget.doubleChild,
              onDismiss: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        ),
      ),
    );
  }

  void _showDoublePush() {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => _PushRoute(
            backButton: ContextualRevealTheme.of(context).backButton,
            child: widget.doubleChild,
          ),
        ),
      ),
    );
  }

  // --- animation ---

  void _fadeIn(Duration duration) {
    _controller.duration = duration;
    unawaited(_controller.forward());
  }

  void _fadeOut(VoidCallback onComplete) {
    _tapTimer?.cancel();
    final theme = ContextualRevealTheme.of(context);
    _controller.duration = theme.fadeOutDuration;
    unawaited(_controller.reverse().whenComplete(onComplete));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: _parentKey,
    onTap: _onTap,
    onLongPressStart: (_) => _onLongPressStart(),
    onLongPressEnd: (_) => _onLongPressEnd(),
    onLongPressCancel: _onLongPressEnd,
    onDoubleTap: _onDoubleTap,
    child: widget.body,
  );
}
