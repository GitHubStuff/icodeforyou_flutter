// programs/creature_comfort/lib/src/firebase/cubit/auth_cubit.dart
// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(const AuthInitial()) {
    _subscription = _auth.authStateChanges().listen(_emitForUser);
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _subscription;

  // Resolves signed-in / signed-out from the current user. Used by the
  // authStateChanges stream (external changes) AND after each operation
  // completes — so a no-op call (e.g. signing out while already signed
  // out) can't strand the state in AuthInProgress waiting for an event
  // that never fires. Equal re-emits are deduped by Equatable.
  void _emitForUser(User? user) {
    if (user == null) {
      emit(const AuthSignedOut());
      return;
    }
    emit(AuthSignedIn(uid: user.uid, email: user.email));
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(const AuthInProgress());
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _emitForUser(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(code: e.code, message: e.message ?? e.code));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthInProgress());
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _emitForUser(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(code: e.code, message: e.message ?? e.code));
    }
  }

  Future<void> signOut() async {
    emit(const AuthInProgress());
    try {
      await _auth.signOut();
      _emitForUser(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(code: e.code, message: e.message ?? e.code));
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
