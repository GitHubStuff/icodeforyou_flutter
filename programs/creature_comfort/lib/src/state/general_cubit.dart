// programs/creature_comfort/lib/src/state/general_cubit.dart
// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:flutter_bloc/flutter_bloc.dart';

import 'general_state.dart' show GeneralState, InitialState, WaitingStart;

class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit() : super(const InitialState());

  void startInit() => emit(const WaitingStart());
}
