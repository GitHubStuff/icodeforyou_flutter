// programs/creature_comfort/lib/src/firebase/cubit/updater_cubit.dart
// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'dart:async';

import 'package:creature_comfort/src/firebase/updater_crud.dart'
    show UpdaterBeacon, UpdaterCrud;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'updater_state.dart';

class UpdaterCubit extends Cubit<UpdaterState> {
  UpdaterCubit({
    required this._crud,
    this.selfEmail,
  })  : super(const UpdaterInitial());

  final UpdaterCrud _crud;

  /// Email of the signed-in user, used to skip our own writes. When null,
  /// no incoming beacon is treated as "self".
  final String? selfEmail;

  StreamSubscription<UpdaterBeacon?>? _subscription;
  bool _primed = false;

  /// Whether this cubit is currently listening to the beacon.
  bool get isSubscribed => _subscription != null;

  /// Starts listening to `shared/updater`. The first (subscribe-time)
  /// emission is swallowed so only later writes are announced. No-op when
  /// already subscribed.
  void subscribe() {
    if (_subscription != null) {
      return;
    }
    _primed = false;
    _subscription = _crud.watch().listen(_onBeacon, onError: _onError);
  }

  /// Stops listening. No-op when not currently subscribed.
  Future<void> unsubscribe() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onBeacon(UpdaterBeacon? beacon) {
    // First emission is the subscribe-time document — not a new change.
    if (!_primed) {
      _primed = true;
      return;
    }
    // Document deleted — nothing to announce.
    if (beacon == null) {
      return;
    }
    // Our own write — don't notify ourselves.
    if (beacon.email == selfEmail) {
      return;
    }
    emit(UpdaterReceived(beacon: beacon));
  }

  void _onError(Object error) {
    emit(UpdaterError(error.toString()));
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
