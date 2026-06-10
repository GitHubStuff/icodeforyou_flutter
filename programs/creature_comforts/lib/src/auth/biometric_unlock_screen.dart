// programs/creature_comforts/lib/src/auth/biometric_unlock_screen.dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:creature_comforts/descriptors/biometric_gate_descriptor.dart';
import 'package:creature_comforts/src/auth/auth_cubit.dart';
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart';

/// "Tap to sign in as <user>" screen — the bank-model unlock UX agreed
/// in Question 3.
///
/// Shown when [AuthState] is [BiometricLocked]. On tap, calls
/// [BiometricGateService.verify] which runs the platform's biometric
/// prompt; on success, calls [AuthCubit.unlockWithBiometric] which
/// transitions the state to [Authenticated] and the auth gate routes to
/// the rail.
///
/// The "Use email & password instead" link calls
/// [AuthCubit.continueWithoutBiometric], which signs out of Firebase and
/// drops the user to [LoginScreen]. Without that signOut, bootstrap on
/// next launch would put them right back here.
class BiometricUnlockScreen extends StatefulWidget {
  const BiometricUnlockScreen({required this.user, super.key});

  final AuthUser user;

  @override
  State<BiometricUnlockScreen> createState() => _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends State<BiometricUnlockScreen> {
  bool _prompting = false;
  String? _failureMessage;
  IconData _biometricIcon = Icons.fingerprint;
  String _biometricLabel = 'Tap to unlock';

  @override
  void initState() {
    super.initState();
    _resolveCapability();
  }

  Future<void> _resolveCapability() async {
    final gate = ServiceRegistry.R.getSync<BiometricGateService>(
      BiometricGateDescriptor.kName,
    );
    final cap = await gate.capability();
    if (!mounted) return;
    setState(() {
      switch (cap) {
        case BiometricCapability.face:
          _biometricIcon = Icons.face;
          _biometricLabel = 'Tap to sign in with Face ID';
        case BiometricCapability.fingerprint:
          _biometricIcon = Icons.fingerprint;
          _biometricLabel = 'Tap to sign in with Touch ID';
        case BiometricCapability.iris:
          _biometricIcon = Icons.visibility;
          _biometricLabel = 'Tap to sign in with iris scan';
        case BiometricCapability.generic:
          _biometricIcon = Icons.lock_outline;
          _biometricLabel = 'Tap to sign in with biometric';
        case BiometricCapability.none:
        case BiometricCapability.notEnrolled:
          // Fail-safe: the auth gate shouldn't put us here in these
          // states, but if it does, dropping straight to password is
          // better than a stuck unlock screen.
          context.read<AuthCubit>().continueWithoutBiometric();
      }
    });
  }

  Future<void> _onUnlockPressed() async {
    setState(() {
      _prompting = true;
      _failureMessage = null;
    });

    final gate = ServiceRegistry.R.getSync<BiometricGateService>(
      BiometricGateDescriptor.kName,
    );
    final result = await gate.verify(
      reason: 'Sign in to Creature Comforts',
    );

    if (!mounted) return;
    setState(() => _prompting = false);

    result.match(
      (failure) => setState(() => _failureMessage = failure.message),
      (_) => context.read<AuthCubit>().unlockWithBiometric(),
    );
  }

  Future<void> _onUsePasswordPressed() async {
    await context.read<AuthCubit>().continueWithoutBiometric();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  IconButton.filled(
                    iconSize: 64,
                    onPressed: _prompting ? null : _onUnlockPressed,
                    icon: _prompting
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : Icon(_biometricIcon),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _biometricLabel,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (_failureMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _failureMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 48),
                  TextButton(
                    onPressed: _prompting ? null : _onUsePasswordPressed,
                    child: const Text('Use email & password instead'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
