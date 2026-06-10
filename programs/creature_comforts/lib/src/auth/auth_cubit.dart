// programs/creature_comforts/lib/src/auth/auth_cubit.dart
import 'dart:async';
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:creature_comforts/src/auth/auth_service.dart';
import 'package:creature_comforts/src/auth/auth_state.dart';
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives the [AuthState] machine that the auth gate in `app.dart`
/// listens to.
///
/// Responsibilities:
///
///  - Read the initial state at app launch via [bootstrap], reconciling
///    the persisted Firebase session with the user's biometric preference.
///  - Subscribe to [AuthService.authStateChanges] so external sign-out
///    events (token expiry, account deletion, sign-out from another
///    device) are reflected immediately.
///  - Expose [signIn], [signOut], [unlockWithBiometric], and
///    [continueWithoutBiometric] as the only mutation paths; the auth gate
///    routes screens by reading state, never by writing.
final class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthService authService,
    BiometricGateService? biometricGate,
  })  : _auth = authService,
        _gate = biometricGate,
        super(const AuthInitializing()) {
    _authSub = _auth.authStateChanges().listen(_onBackendUserChanged);
  }

  final AuthService _auth;
  final BiometricGateService? _gate;
  late final StreamSubscription<AuthUser?> _authSub;

  /// Resolves the initial state.
  ///
  /// Three terminal possibilities:
  ///   - No persisted session                  → [Unauthenticated]
  ///   - Persisted session, biometric disabled → [Authenticated]
  ///   - Persisted session, biometric enabled  → [BiometricLocked]
  ///
  /// If the biometric gate is unavailable (no impl injected, capability
  /// check fails, preference read throws), the user is treated as
  /// "biometric not enabled" — they see [Authenticated] directly. This
  /// fails open intentionally: a broken gate should never lock the user
  /// out of an already-signed-in app.
  Future<void> bootstrap() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const Unauthenticated());
      return;
    }

    final shouldGate = await _shouldShowBiometricGate();
    emit(
      shouldGate ? BiometricLocked(user: user) : Authenticated(user: user),
    );
  }

  /// Attempts sign-in with [email] and [password]. On success, lands in
  /// [Authenticated] (no biometric gate on first sign-in — the user just
  /// proved their credentials). On failure, lands in [Unauthenticated]
  /// with the failure attached for inline display on the login screen.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signIn(email: email, password: password);
    result.match(
      (failure) => emit(Unauthenticated(failure: failure)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Signs the user out. Drops to [Unauthenticated] on success; emits a
  /// new [Unauthenticated] state regardless because that's the only sane
  /// terminal state for a sign-out attempt — even if the SDK call fails,
  /// the user wanted out, and the auth state stream will reconcile.
  Future<void> signOut() async {
    await _auth.signOut();
    emit(const Unauthenticated());
  }

  /// Called by the unlock screen after a successful biometric prompt.
  /// Transitions [BiometricLocked] → [Authenticated] for the same user.
  ///
  /// No-op if the current state isn't [BiometricLocked].
  void unlockWithBiometric() {
    final current = state;
    if (current is BiometricLocked) {
      emit(Authenticated(user: current.user));
    }
  }

  /// Called by the unlock screen's "use email & password instead" link.
  /// Transitions [BiometricLocked] → [Unauthenticated], forcing the user
  /// through the login screen. Does not sign them out of Firebase — the
  /// session stays alive in case they change their mind, but the auth
  /// gate hides the rail until they re-prove credentials.
  ///
  /// No-op if the current state isn't [BiometricLocked].
  Future<void> continueWithoutBiometric() async {
    if (state is BiometricLocked) {
      await _auth.signOut();
      emit(const Unauthenticated());
    }
  }

  /// Whether to show the biometric gate at bootstrap.
  ///
  /// Three reasons to *not* show it:
  ///   1. No gate impl injected.
  ///   2. The user never opted in.
  ///   3. The device's biometric capability is now `none` or `notEnrolled`
  ///      (user removed their face/fingerprint after enabling the gate).
  ///
  /// Reading the preference and capability are best-effort; any thrown
  /// exception falls through to "no gate" so a broken gate doesn't lock
  /// the user out.
  Future<bool> _shouldShowBiometricGate() async {
    final gate = _gate;
    if (gate == null) return false;
    try {
      final enabled = await gate.isEnabled();
      if (!enabled) return false;
      final cap = await gate.capability();
      return switch (cap) {
        BiometricCapability.none ||
        BiometricCapability.notEnrolled => false,
        _ => true,
      };
    }
    // ignore: avoid_catches_without_on_clauses
    catch (_) {
      return false;
    }
  }

  /// Reacts to backend-driven auth changes (sign-out from another device,
  /// session expiry, account deletion). Only fires for terminal
  /// transitions: a backend sign-in is never the way our user enters
  /// [Authenticated] — that path goes through [signIn] which has full
  /// context (success vs failure mapping).
  void _onBackendUserChanged(AuthUser? user) {
    if (user == null && state is! Unauthenticated) {
      emit(const Unauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _authSub.cancel();
    return super.close();
  }
}
