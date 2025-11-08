// feeding_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/feeding_data.dart';
import '../../../../domain/repositories/feeding_repository.dart';
import 'feeding_state.dart';

/// Manages feeding data state
/// Single Responsibility: Coordinate feeding data operations
class FeedingCubit extends Cubit<FeedingState> {
  final FeedingRepository _repository;

  FeedingCubit({required FeedingRepository repository})
    : _repository = repository,
      super(FeedingInitial()) {
    loadFeeding();
  }

  /// Load current feeding data
  Future<void> loadFeeding() async {
    emit(FeedingLoading());

    try {
      final data = await _repository.getCurrentFeeding();
      if (data != null) {
        emit(FeedingLoaded(data: data));
      } else {
        emit(FeedingEmpty());
      }
    } catch (e) {
      emit(FeedingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Update feeding with current user and time
  Future<void> updateFeeding(String userName) async {
    emit(FeedingLoading());

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final data = FeedingData(name: userName, epoc: now);

      await _repository.updateFeeding(data);
      emit(FeedingLoaded(data: data));
    } catch (e) {
      emit(FeedingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Watch for real-time updates
  void watchFeeding() {
    _repository.watchFeeding().listen(
      (data) {
        if (data != null) {
          emit(FeedingLoaded(data: data));
        } else {
          emit(FeedingEmpty());
        }
      },
      onError: (error) {
        emit(FeedingError(message: error.toString()));
      },
    );
  }
}
