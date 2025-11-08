// feeding_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/feeding_data.dart';

/// States for feeding data
abstract class FeedingState extends Equatable {
  const FeedingState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state
class FeedingInitial extends FeedingState {}

/// Loading feeding data
class FeedingLoading extends FeedingState {}

/// Feeding data loaded
class FeedingLoaded extends FeedingState {
  final FeedingData data;

  const FeedingLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

/// No feeding data found
class FeedingEmpty extends FeedingState {}

/// Error loading feeding data
class FeedingError extends FeedingState {
  final String message;

  const FeedingError({required this.message});

  @override
  List<Object?> get props => [message];
}
