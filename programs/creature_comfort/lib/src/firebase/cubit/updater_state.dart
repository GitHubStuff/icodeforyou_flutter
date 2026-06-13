// programs/creature_comfort/lib/src/firebase/cubit/updater_state.dart
// ignore_for_file: public_member_api_docs

import 'package:creature_comfort/src/firebase/updater_crud.dart'
    show UpdaterBeacon;
import 'package:equatable/equatable.dart';

sealed class UpdaterState extends Equatable {
  const UpdaterState();

  @override
  List<Object?> get props => [];
}

/// Listening, but no qualifying update has arrived yet.
final class UpdaterInitial extends UpdaterState {
  const UpdaterInitial();
}

/// Someone else wrote the beacon — a change worth announcing.
final class UpdaterReceived extends UpdaterState {
  const UpdaterReceived({required this.beacon});

  final UpdaterBeacon beacon;

  @override
  List<Object?> get props => [beacon];
}

/// The beacon stream errored.
final class UpdaterError extends UpdaterState {
  const UpdaterError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
