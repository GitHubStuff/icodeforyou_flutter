// programs/creature_comfort/lib/src/screens/widgets_page.dart
import 'package:creature_comfort/src/firebase/updater_crud.dart'
    show UpdaterCrud;
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

/// {@template widgets_page}
/// A page that reacts to [GeneralState] emitted by [GeneralCubit] and renders
/// a state-specific view.
///
/// The page listens through a [BlocBuilder] and switches on the current
/// [GeneralState]:
///
/// * [InitialState] — shows the landing content with two actions: an **Init**
///   button that kicks off the cubit's initialization flow and drives the
///   [Setup] pipeline, and an **Updater** button that performs a Firestore
///   write via [UpdaterCrud].
/// * [WaitingStart] — shows a [SizedSpinner] while work is in progress.
/// * [WaitingFinished] — currently unhandled.
///
/// The widget itself is stateless; all mutable state is owned by the ambient
/// [GeneralCubit] read from the [BuildContext].
/// {@endtemplate}
class WidgetsPage extends StatelessWidget {
  /// {@macro widgets_page}
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
                  const Gap(4),
                  ElevatedButton(
                    onPressed: () async {
                      context.read<GeneralCubit>().startInit();
                      await Setup.initDOM();
                      await Setup.loadIn();
                    },
                    child: const Text('Init', style: defStyle),
                  ),
                  const Gap(4),
                  ElevatedButton(
                    onPressed: () async {
                      final crud = UpdaterCrud();
                      await crud.write(
                        email: 'steven@icodeforyou.com',
                        name: 'Steven',
                        timestamp: DateTime.now().microsecondsSinceEpoch,
                      );
                    },
                    child: const Text('Updater', style: defStyle),
                  ),
                ],
              ),
              // TODO(steven): Handle the WaitingFinished case.
              WaitingFinished() => throw UnimplementedError(),
              WaitingStart() => const SizedSpinner(size: 100),
            };
          },
        ),
      ),
    );
  }
}
