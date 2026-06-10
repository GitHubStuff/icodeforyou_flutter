// ignore_for_file: public_member_api_docs

import 'package:creature_comfort/src/data/data_transfer.dart' show SinceWhenController;
import 'package:creature_comfort/src/setup/setup.dart';
import 'package:creature_comfort/src/state/general_cubit.dart'
    show GeneralCubit;
import 'package:creature_comfort/src/state/general_state.dart'
    show GeneralState, InitialState, WaitingFinished, WaitingStart;
import 'package:creature_comfort/src/typedef.dart' show defStyle;
import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart' show Gap;

class WidgetsPage extends StatelessWidget {
  const WidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<GeneralCubit, GeneralState>(
          builder: (context, state) {
            return switch (state) {
              InitialState() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Widget Page $state',
                    style: defStyle,
                  ),
                  const Gap(8),
                  ElevatedButton(
                    onPressed: () async {
                      context.read<GeneralCubit>().startInit();
                      await Setup.initDOM();
                      await Setup.loadIn();
                      
                    },
                    child: const Text('Init', style: defStyle),
                  ),
                ],
              ),
              // TODO: Handle this case.
              WaitingFinished() => throw UnimplementedError(),

              WaitingStart() => const SizedSpinner(size: 100),
            };
          },
        ),
      ),
    );
  }
}
