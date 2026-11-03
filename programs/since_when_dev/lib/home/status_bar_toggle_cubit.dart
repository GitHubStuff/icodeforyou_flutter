// programs/since_when_dev/lib/home/status_bar_toggle_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

/// Exposes the status bar's hidden state and lets the UI change it.
///
/// The state is always read back from the service after a change, so the
/// UI reflects what the platform actually applied, not what was requested.
class StatusBarToggleCubit extends Cubit<bool> {
  /// Creates a cubit whose initial state is the service's current state.
  StatusBarToggleCubit(this._statusBar) : super(_statusBar.isBarHidden());

  final StatusBarVisibilityAbstract _statusBar;

  /// Asks the platform to hide or show the status bar.
  ///
  /// Emits only if the platform applied the change.
  Future<void> setHidden({required bool isHidden}) async {
    final applied = await _statusBar.setStatusBarVisibility(
      isHidden: isHidden,
    );
    if (applied && !isClosed) {
      emit(_statusBar.isBarHidden());
    }
  }
}
