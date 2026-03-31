// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'spinner_state.dart';

class SpinnerCubit extends Cubit<SpinnerState> {
  SpinnerCubit() : super(const SpinnerState());

  static const name = 'SpinnerCubitName';

  void show() => emit(state.copyWith(status: SpinnerStatus.visible));
  void hide() => emit(state.copyWith(status: SpinnerStatus.hidden));

  Widget get spinnerWidget => const ColoredBox(
    color: Colors.black45,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}
