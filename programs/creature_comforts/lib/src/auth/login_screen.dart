// programs/creature_comforts/lib/src/auth/login_screen.dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:creature_comforts/descriptors/biometric_gate_descriptor.dart';
import 'package:creature_comforts/src/auth/auth_cubit.dart';
import 'package:creature_comforts/src/auth/auth_service.dart';
import 'package:creature_comforts/src/auth/auth_state.dart';
import 'package:creature_comforts/src/auth/failures/auth_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart';

/// Email + password sign-in form.
///
/// Shown when [AuthState] is [Unauthenticated]. Owns its own local form
/// state (text controllers, validation, "signing in" spinner) but
/// delegates the actual sign-in to [AuthCubit.signIn].
///
/// Includes the "Use biometric next time" toggle that records the user's
/// biometric preference *after* a successful sign-in — toggling without
/// signing in does nothing visible.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _enableBiometricNextTime = false;
  bool _signingIn = false;
  bool _showCapabilityToggle = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _resolveBiometricCapability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resolveBiometricCapability() async {
    final gate = ServiceRegistry.R.getSync<BiometricGateService>(
      BiometricGateDescriptor.kName,
    );
    final cap = await gate.capability();
    if (!mounted) return;
    setState(() {
      _showCapabilityToggle = switch (cap) {
        BiometricCapability.none ||
        BiometricCapability.notEnrolled => false,
        _ => true,
      };
    });
  }

  Future<void> _onSignInPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _signingIn = true);
    final cubit = context.read<AuthCubit>();
    await cubit.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _signingIn = false);

    // If sign-in succeeded and the user opted in, enable the gate now.
    // Reading state directly is safe because cubit emissions are sync.
    if (cubit.state is Authenticated && _enableBiometricNextTime) {
      final gate = ServiceRegistry.R.getSync<BiometricGateService>(
        BiometricGateDescriptor.kName,
      );
      await gate.enable();
    }
  }

  Future<void> _onForgotPasswordPressed() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Enter your email first.');
      return;
    }
    final auth = ServiceRegistry.R.getSync<AuthService>('AuthService');
    final result = await auth.sendPasswordResetEmail(email: email);
    if (!mounted) return;
    result.match(
      (failure) => _showSnack(failure.message),
      (_) => _showSnack('Password reset email sent.'),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _togglePasswordVisible() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  void _onBiometricToggle({required bool value}) {
    setState(() => _enableBiometricNextTime = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final failure =
                        state is Unauthenticated ? state.failure : null;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HeaderText(),
                        const SizedBox(height: 32),
                        _EmailField(
                          controller: _emailController,
                          enabled: !_signingIn,
                        ),
                        const SizedBox(height: 16),
                        _PasswordField(
                          controller: _passwordController,
                          enabled: !_signingIn,
                          visible: _passwordVisible,
                          onToggleVisible: _togglePasswordVisible,
                          onSubmitted: _onSignInPressed,
                        ),
                        if (_showCapabilityToggle) ...[
                          const SizedBox(height: 16),
                          _BiometricToggle(
                            value: _enableBiometricNextTime,
                            enabled: !_signingIn,
                            onChanged: _onBiometricToggle,
                          ),
                        ],
                        if (failure != null) ...[
                          const SizedBox(height: 16),
                          _FailureBanner(failure: failure),
                        ],
                        const SizedBox(height: 24),
                        _SignInButton(
                          busy: _signingIn,
                          onPressed: _onSignInPressed,
                        ),
                        const SizedBox(height: 8),
                        _ForgotPasswordButton(
                          enabled: !_signingIn,
                          onPressed: _onForgotPasswordPressed,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered "Sign in" headline at the top of the form.
class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sign in',
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }
}

/// Email entry with autofill and basic shape validation.
class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  String? _validate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email required';
    if (!v.contains('@')) return 'Invalid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      validator: _validate,
    );
  }
}

/// Password entry with a show/hide visibility toggle.
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.visible,
    required this.onToggleVisible,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool visible;
  final VoidCallback onToggleVisible;
  final Future<void> Function() onSubmitted;

  String? _validate(String? value) {
    if ((value ?? '').isEmpty) return 'Password required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: !visible,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          tooltip: visible ? 'Hide password' : 'Show password',
          onPressed: enabled ? onToggleVisible : null,
        ),
      ),
      validator: _validate,
      onFieldSubmitted: (_) => onSubmitted(),
    );
  }
}

/// "Use biometric next time" switch shown only when the device supports
/// biometric authentication.
class _BiometricToggle extends StatelessWidget {
  const _BiometricToggle({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final void Function({required bool value}) onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? (v) => onChanged(value: v) : null,
      title: const Text('Use biometric next time'),
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Primary action button. Renders a spinner in place of the label while
/// a sign-in attempt is in flight.
class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.busy, required this.onPressed});

  final bool busy;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Sign in'),
    );
  }
}

/// Secondary "Forgot password?" link below the sign-in button.
class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: const Text('Forgot password?'),
    );
  }
}

/// Inline error banner shown above the sign-in button when a sign-in
/// attempt failed.
class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.failure});

  final AuthFailure failure;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              failure.message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
