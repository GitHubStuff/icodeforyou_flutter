// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class OverlayHostCubit extends Cubit<Widget?> {
  OverlayHostCubit() : super(null);

  void showOverlay(Widget child) => emit(child);

  void updateOverlay(Widget child) => emit(child);

  void removeOverlay() => emit(null);
}
