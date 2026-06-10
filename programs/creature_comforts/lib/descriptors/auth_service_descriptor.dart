// programs/creature_comforts/lib/descriptors/auth_service_descriptor.dart

import 'package:service_locator/service_locator.dart'
    show SyncServiceDescriptor;

/// Service-locator descriptor for [AuthService].
///
/// Registers an [AuthServiceFirebase] as a synchronous singleton. The
/// constructor reads `FirebaseAuth.instance`, which is already
/// initialized in `main.dart` via `Firebase.initializeApp()` before
/// staging fires.
class AuthServiceDescriptor extends SyncServiceDescriptor<AuthService> {
  const AuthServiceDescriptor();

  /// Canonical name. Use this everywhere instead of the literal string.
  static const String kName = 'AuthService';

  @override
  String get name => kName;

  @override
  AuthService Function() get builder => AuthServiceFirebase.new;
}
