// test/src/popover_layout_delegate_relayout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:position_popover/position_popover.dart';

/// _PopoverLayoutDelegate is private (part-of), so shouldRelayout cannot be
/// called directly. We drive it through CustomSingleChildLayout: re-showing a
/// centered popover with a different childSize keeps chain/anchor/bounds equal
/// and changes ONLY delegate.maxSize, forcing the final `||` operand
/// (maxSize != oldDelegate.maxSize) to decide the relayout.
void main() {
  testWidgets('relayouts when only maxSize changes', (tester) async {
    await tester.pumpWidget(const _Host(childSize: Size(200, 200)));
    await tester.pump(); // post-frame show
    await tester.pump(); // overlay frame
    expect(find.byKey(const Key('popover-child')), findsOneWidget);

    // Change only childSize -> only the delegate's maxSize differs.
    await tester.pumpWidget(const _Host(childSize: Size(300, 300)));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('popover-child')), findsOneWidget);
  });
}

/// Shows a centered popover and re-shows it whenever [childSize] changes.
class _Host extends StatefulWidget {
  const _Host({required this.childSize});
  final Size childSize;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  PopoverHandle? _handle;
  BuildContext? _overlayContext;

  void _show() {
    final context = _overlayContext;
    if (context == null) return;
    _handle?.dismiss();
    _handle = PositionPopover(
      position: PopoverPosition.center(),
      childSize: widget.childSize,
      barrierColor: Colors.transparent,
      child: const SizedBox(
        key: Key('popover-child'),
        width: 50,
        height: 50,
      ),
    ).show(context);
  }

  @override
  void didUpdateWidget(_Host oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childSize != widget.childSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            _overlayContext = context;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_handle == null) _show();
            });
            return const SizedBox.expand();
          },
        ),
      ),
    );
  }
}
