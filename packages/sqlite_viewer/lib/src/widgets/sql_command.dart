// packages/sqlite_viewer/lib/src/widgets/sql_command.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart'
    show ExpandingTextField, SaveCancelBar, UniformCluster;
import 'package:flutter/material.dart';
import 'package:position_popover/position_popover.dart'
    show PopoverHandle, PositionPopover;

const TextStyle _style = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final TextEditingController _controller = TextEditingController();
late PopoverHandle? _popoverHandle;

class SqlCommand extends StatelessWidget {
  const SqlCommand({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _popoverHandle = PositionPopover(
          barrierDismissible: false,
          child: _editor(context),
        ).show(context);
      },
      child: _child(),
    );
  }

  Widget _child() {
    return const Text(
      'Enter SQL commands',
      style: _style,
    );
  }

  Widget _editor(BuildContext context) {
    return UniformCluster(
      axis: .vertical,
      children: [
        Center(child: _child()),
        _editText(context),
        _bar(),
      ],
    );
  }

  Widget _editText(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.75,
      child: ExpandingTextField(
        controller: _controller,
        onChanged: (string) {
          debugPrint(string);
        },
      ),
    );
  }

  Widget _bar() {
    return SaveCancelBar(
      onCancel: () {
        _popoverHandle?.dismiss();
      },
      onSave: () {
        _popoverHandle?.dismiss();
      },
    );
  }
}
