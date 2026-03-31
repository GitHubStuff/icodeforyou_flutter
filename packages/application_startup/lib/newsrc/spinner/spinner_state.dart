part of 'spinner_cubit.dart';

enum SpinnerStatus { visible, hidden }

final class SpinnerState {
  const SpinnerState({this.status = SpinnerStatus.hidden});

  final SpinnerStatus status;

  bool get isVisible => status == SpinnerStatus.visible;

  SpinnerState copyWith({SpinnerStatus? status}) =>
      SpinnerState(status: status ?? this.status);
}
