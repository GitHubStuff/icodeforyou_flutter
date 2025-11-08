// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/firebase_auth_service.dart';
import '../widgets/login_form.dart';
import 'auth/bloc/auth_bloc.dart';
import 'auth/bloc/auth_event.dart';
import 'auth/bloc/auth_state.dart';
import 'home_screen.dart';

/// Login screen constants
class _LoginScreenConstants {
  static const double logoPadding = 24.0;
  static const double logoSize = 80.0;
  static const double logoBottomSpacing = 16.0;
  static const double titleFontSize = 24.0;
  static const double formTopSpacing = 48.0;
}

/// Login screen strings
class _LoginScreenStrings {
  static const String appTitle = 'Critter Feeding Tracker';
}

/// Main login screen
/// Single Responsibility: Coordinate authentication flow
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: FirebaseAuthService()),
      child: const _LoginView(),
    );
  }
}

/// Login view separated from provider logic
class _LoginView extends StatelessWidget {
  const _LoginView();

  void _handleSignIn(BuildContext context, String email, String password) {
    context.read<AuthBloc>().add(
      SignInRequested(email: email, password: password),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateToHome(context);
        } else if (state is AuthError) {
          _showError(context, state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_LoginScreenConstants.logoPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _AppLogo(),
                  const SizedBox(height: _LoginScreenConstants.formTopSpacing),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return LoginForm(
                        onSubmit: (email, password) =>
                            _handleSignIn(context, email, password),
                        isLoading: state is AuthLoading,
                      );
                    },
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

/// App logo and branding
class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.pets,
          size: _LoginScreenConstants.logoSize,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: _LoginScreenConstants.logoBottomSpacing),
        const Text(
          _LoginScreenStrings.appTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _LoginScreenConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
