// packages/mypickdf/lib/src/mypickdf.dart

import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
    show DatePicker, TimePicker;
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart' show Gap;

/// Gateway class
class ArcheTypes extends StatefulWidget {
  ///
  const ArcheTypes({super.key});

  @override
  State<ArcheTypes> createState() => _ArcheTypes();
}

class _ArcheTypes extends State<ArcheTypes> {
  @override
  Widget build(BuildContext context) {
    return const Body();
  }
}

///
class Body extends StatelessWidget {
  ///
  const Body({super.key});

  static const Size _pickerSize = Size(215, 150);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(25),
        DatePicker(
          onDateChanged: (p1) {
            debugPrint('$p1');
          },
          pickerSize: _pickerSize,
        ),

        const Gap(5),
        TimePicker(
          onTimeChanged: (time) {
            debugPrint('$time');
          },
          showSeconds: true,
          size: .compact,
        ),
      ],
    );
  }
}
