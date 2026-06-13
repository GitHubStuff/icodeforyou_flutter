// programs/creature_comfort/lib/src/screens/login_page.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show unawaited;

import 'package:creature_comfort/src/firebase/cubit/auth_cubit.dart'
    show AuthCubit;
import 'package:creature_comfort/src/firebase/cubit/auth_state.dart'
    show
        AuthFailure,
        AuthInProgress,
        AuthInitial,
        AuthSignedIn,
        AuthSignedOut,
        AuthState;
import 'package:creature_comfort/src/typedef.dart' show defStyle;
import 'package:custom_widgets/custom_widgets.dart'
    show PasswordField, SizedSpinner;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart' show Gap;

// ---------------------------------------------------------------------------
// Tunables — single place to tweak this dev page.
// ---------------------------------------------------------------------------

// Layout.
const double _kPagePadding = 16;
const double _kTitleGap = 16;
const double _kFieldGap = 12;
const double _kActionsGap = 16;
const double _kStatusGap = 24;
const double _kButtonSpacing = 12;
const double _kSpinnerSize = 36;

// Colors.
const Color _kFailureColor = Colors.red;

// Icons.
const IconData _kShowPasswordIcon = Icons.visibility;
const IconData _kHidePasswordIcon = Icons.visibility_off;

// Labels.
const String _kTitle = 'Login';
const String _kEmailLabel = 'Email';
const String _kPasswordLabel = 'Password';
const String _kRegisterLabel = 'Register';
const String _kLoginLabel = 'Login';
const String _kSignOutLabel = 'Sign out';
const String _kInitializing = 'Initializing…';
const String _kSignedOut = 'Signed out';
const String _kSignedIn = 'Signed in';
const String _kFailedPrefix = 'Failed:';

// ---------------------------------------------------------------------------

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();
  String get _password => _passwordController.text;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_kPagePadding),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            final busy = state is AuthInProgress;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(_kTitle, style: defStyle),
                const Gap(_kTitleGap),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: _kEmailLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const Gap(_kFieldGap),
                PasswordField(
                  controller: _passwordController,
                  passwordLabel: _kPasswordLabel,
                  showTextIcon: const Icon(_kShowPasswordIcon),
                  hideTextIcon: const Icon(_kHidePasswordIcon),
                ),
                const Gap(_kActionsGap),
                Wrap(
                  spacing: _kButtonSpacing,
                  runSpacing: _kButtonSpacing,
                  children: [
                    ElevatedButton(
                      onPressed: busy
                          ? null
                          : () => unawaited(
                              cubit.register(
                                email: _email,
                                password: _password,
                              ),
                            ),
                      child: const Text(_kRegisterLabel),
                    ),
                    ElevatedButton(
                      onPressed: busy
                          ? null
                          : () => unawaited(
                              cubit.login(
                                email: _email,
                                password: _password,
                              ),
                            ),
                      child: const Text(_kLoginLabel),
                    ),
                    OutlinedButton(
                      onPressed: busy ? null : () => unawaited(cubit.signOut()),
                      child: const Text(_kSignOutLabel),
                    ),
                  ],
                ),
                const Gap(_kStatusGap),
                _StatusLine(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.state});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AuthInitial() => const Text(_kInitializing),
      AuthInProgress() => const SizedSpinner(size: _kSpinnerSize),
      AuthSignedOut() => const Text(_kSignedOut),
      AuthSignedIn(:final email, :final uid) => Text(
        '$_kSignedIn\n$email\n$uid',
      ),
      AuthFailure(:final code, :final message) => Text(
        '$_kFailedPrefix $code\n$message',
        style: const TextStyle(color: _kFailureColor),
      ),
    };
  }
}
