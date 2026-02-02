// lib/src/_slider_cubit.dart
part of 'step_slider.dart';

/// Internal cubit for managing slider state.
///
/// This is intentionally private to the package. Each [StepSlider]
/// creates its own instance, ensuring isolated state management.
class _SliderCubit extends Cubit<double> {
  _SliderCubit({double initial = 0.0}) : super(initial);

  /// Updates the slider value.
  void update(double value) => emit(value);
}
