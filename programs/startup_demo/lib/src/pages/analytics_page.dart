// lib/src/pages/analytics_page.dart

// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:custom_widgets/custom_widgets.dart';
import 'package:extensions/extensions.dart' show ColorExtension;
import 'package:extensions/widget_ext/widget_ext.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:startup_demo/src/pages/analytics_page/scrollable_content_widget.dart';

const TextStyle _buttonStyle = TextStyle(color: Colors.green, fontSize: 24);
const TextStyle _popoverStyle = TextStyle(color: Colors.purple, fontSize: 24);

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Gap(18),
              AboveWidget(),
              const Gap(4),
              BelowWidget(),
              const Gap(4),
              const CenterWidget(),
              const Gap(4),
              LeftWidget(),
              const Gap(4),
              RightWidget(),
              const Gap(4),
              RightBigWidget(),
              const Gap(4),
              AboveSQLWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class AboveSQLWidget extends StatelessWidget {
  AboveSQLWidget({super.key});

  final GlobalKey leftKey = GlobalKey();

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: leftKey,
    onPressed: () => AnimatedBarrier(
      position: PopoverPosition.above(leftKey),
      child: ColoredBox(
        color: Colors.deepPurpleAccent.withAlphaValue(0.9),
        child: SqlWidget01(),
      ),
    ).show(context),
    child: const Text(
      'Show SQL Above',
      style: _buttonStyle,
    ),
  );
}

class SqlWidget01 extends StatelessWidget {
  SqlWidget01({super.key});

  final TextEditingController _textEditingController = TextEditingController(
    text: 'Sql\n1',
  );

  @override
  Widget build(BuildContext context) => ExpandingTextField(
    controller: _textEditingController,
    onChanged: (txt) {
      debugPrint('1- $txt');
    },
  );
}

class SqlWidget02 extends StatelessWidget {
  SqlWidget02({super.key});

  final TextEditingController _textEditingController = TextEditingController(
    text: 'Sql line number\n2\nof.. fuck i dont\nR',
  );

  @override
  Widget build(BuildContext context) => ExpandingTextField(
    controller: _textEditingController,
    onChanged: (txt) {
      debugPrint('2- $txt');
    },
  );
}

class SqlWidget03 extends StatelessWidget {
  SqlWidget03({super.key});

  final TextEditingController _textEditingController = TextEditingController(
    text: 'Sql line number\n3\nThis is getting...\n kinda borning\nyou know',
  );

  @override
  Widget build(BuildContext context) => ExpandingTextField(
    controller: _textEditingController,
    onChanged: (txt) {
      debugPrint('3- $txt');
    },
  );
}

class SqlWidget04 extends StatelessWidget {
  SqlWidget04({super.key});

  final TextEditingController _textEditingController = TextEditingController(
    text:
        'Now the fourth line, this is a test of autowrapping the content, so'
        ' This line is long enough it should cause a wrap',
  );

  @override
  Widget build(BuildContext context) => ExpandingTextField(
    controller: _textEditingController,
    onChanged: (txt) {
      debugPrint('3- $txt');
    },
  );
}

class AboveWidget extends StatelessWidget {
  AboveWidget({super.key});

  final GlobalKey leftKey = GlobalKey();

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: leftKey,
    onPressed: () => AnimatedBarrier(
      position: PopoverPosition.above(leftKey),
      child: ColoredBox(
        color: Colors.grey,
        child: CrossFadeWidgets(
          duration: const Duration(milliseconds: 500),
          onIndexChanged: (indx) {
            debugPrint('Index $indx');
          },
          children: [
            SqlWidget01(),
            SqlWidget02(),
            SqlWidget03(),
            SqlWidget04(),
          ],
        ).withPaddingAll(8),
      ),
    ).show(context),
    child: const Text(
      'Show Above',
      style: _buttonStyle,
    ),
  );
}

class BelowWidget extends StatelessWidget {
  BelowWidget({super.key});

  final GlobalKey leftKey = GlobalKey();

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: leftKey,
    onPressed: () => AnimatedBarrier(
      position: PopoverPosition.below(leftKey),
      child: const Text('Below Side', style: _popoverStyle),
    ).show(context),
    child: const Text(
      'Show Below',
      style: _buttonStyle,
    ),
  );
}

class CenterWidget extends StatelessWidget {
  const CenterWidget({super.key});
  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: () => AnimatedBarrier(
      barrierColor: Colors.deepPurple.withAlphaValue(0.3),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Centered popover.',
          style: _popoverStyle,
        ),
      ),
    ).show(context),
    child: const Text(
      'Show Center',
      style: _buttonStyle,
    ),
  );
}

class LeftWidget extends StatelessWidget {
  LeftWidget({super.key});

  final GlobalKey leftKey = GlobalKey();

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: leftKey,
    onPressed: () => AnimatedBarrier(
      position: PopoverPosition.left(leftKey),
      child: const Text('Left Side', style: _popoverStyle),
    ).show(context),
    child: const Text(
      'Show Left',
      style: _buttonStyle,
    ),
  );
}

class RightWidget extends StatelessWidget {
  RightWidget({super.key});

  final GlobalKey rightKey = GlobalKey();

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: rightKey,
    onPressed: () => AnimatedBarrier(
      position: PopoverPosition.right(rightKey),
      child: const Text('Right Side', style: _popoverStyle),
    ).show(context),
    child: const Text(
      'Show Right',
      style: _buttonStyle,
    ),
  );
}

class RightBigWidget extends StatelessWidget {
  RightBigWidget({super.key});

  final GlobalKey rightKey = GlobalKey();

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: rightKey,
    onPressed: () => AnimatedBarrier(
      position: PopoverPosition.right(rightKey),
      child: const ScrollableContentWidget(
        size: Size(300, 400),
      ).withBorder(color: Colors.green.contrastingTextColor()),
    ).show(context),
    child: const Text(
      'Show Big Right',
      style: _buttonStyle,
    ),
  );
}
