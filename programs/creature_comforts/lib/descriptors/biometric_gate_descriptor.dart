// programs/creature_comforts/lib/descriptors/biometric_gate_descriptor.dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:service_locator/service_locator.dart';

/// Service-locator descriptor for [BiometricGateService].
///
/// Registers a [BiometricGateServiceLocal] as a synchronous singleton.
/// All construction is in-memory (defaults to `LocalAuthentication()` and
/// `FlutterSecureStorage()`); no I/O happens until the first method call.
class BiometricGateDescriptor
    extends SyncServiceDescriptor<BiometricGateService> {
  const BiometricGateDescriptor();

  /// Canonical name. Use this everywhere instead of the literal string.
  static const String kName = 'BiometricGateService';

  @override
  String get name => kName;

  @override
  BiometricGateService Function() get builder => BiometricGateServiceLocal.new;
}
