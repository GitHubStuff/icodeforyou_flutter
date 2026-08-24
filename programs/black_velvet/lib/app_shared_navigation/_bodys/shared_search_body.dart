import 'package:custom_widgets/custom_widgets.dart' show IceChip;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart';

/// Simple/sample body for the 'Search' button/option
class SharedSearchBody extends StatefulWidget {
  ///
  const SharedSearchBody({super.key});

  @override
  State<SharedSearchBody> createState() => _SharedSearchBody();
}

class _SharedSearchBody extends State<SharedSearchBody> {
  bool showBorder = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SEARCH PAGE'),
      centerTitle: true, // Centers the title horizontally
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IceChip(
                const Text('Sample'),
                backgroundColor: Colors.purpleAccent,
                showBorder: showBorder,
                onPress: () => setState(() {
                  showBorder = !showBorder;
                }),
              ),
              const Gap(8),
              const AnimatedPrismBubble(width: 200, height: 200),
              const Gap(4),
              const DynamicPrismBubble(
                width: 200,
                height: 200,
                dynamicPreset: .tidal,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IceChip(
        const Text('Sample'),
        backgroundColor: Colors.purpleAccent,
        showBorder: showBorder,
        onPress: () => setState(() {
          showBorder = !showBorder;
        }),
      ),
      const PrismBubbleWidget(
        width: 100,
        height: 100,
      ),
    ],
  );
}
