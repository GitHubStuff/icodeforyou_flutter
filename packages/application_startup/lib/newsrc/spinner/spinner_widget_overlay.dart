// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/spinner/spinner_cubit.dart'
    show SpinnerCubit, SpinnerState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpinnerWidgetOverlay extends StatelessWidget {
  const SpinnerWidgetOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpinnerCubit, SpinnerState>(
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.isVisible) context.read<SpinnerCubit>().spinnerWidget,
          ],
        );
      },
    );
  }
}
