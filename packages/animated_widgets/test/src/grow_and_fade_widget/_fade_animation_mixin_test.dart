// animated_widgets/test/src/grow_and_fade_widget/_fade_animation_mixin_test.dart

import 'package:animated_widgets/src/grow_and_fade_widget/_fade_animation_mixin.dart'
    show FadeAnimationMixin;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal host that uses the mixin the way it is intended: inside a State
/// with a real ticker provider driving an AnimationController.
class _Host extends StatefulWidget {
  const _Host({required this.curve});

  final Curve curve;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host>
    with SingleTickerProviderStateMixin, FadeAnimationMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    initFadeAnimation(controller: controller, curve: widget.curve);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  group('FadeAnimationMixin', () {
    testWidgets('maps the controller 0.0→1.0 onto opacity 0.0→1.0',
        (tester) async {
      await tester.pumpWidget(const _Host(curve: Curves.linear));
      final host = tester.state<_HostState>(find.byType(_Host));

      expect(host.fadeAnimation.value, 0.0);

      host.controller.value = 0.5;
      expect(host.fadeAnimation.value, 0.5);

      host.controller.value = 1.0;
      expect(host.fadeAnimation.value, 1.0);
    });
  });
}
