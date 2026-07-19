// programs/creature_comfort/lib/src/state/general_state.dart
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

sealed class GeneralState extends Equatable {
  const GeneralState();
  @override
  List<Object?> get props => [];
}

final class InitialState extends GeneralState {
  const InitialState();
}

final class WaitingFinished extends GeneralState {
  const WaitingFinished();
}

final class WaitingStart extends GeneralState {
  const WaitingStart();
}
