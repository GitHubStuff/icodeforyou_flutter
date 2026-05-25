// lib/src/pick_manager_cubit.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';

class PickManagerCubit extends Cubit<Map<String, Object>> {
  PickManagerCubit() : super({});

  void setItem(String pickerId, Object item) =>
      emit({...state, pickerId: item});

  T? getItem<T>(String pickerId) => state[pickerId] as T?;
}
