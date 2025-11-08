import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// UI constants for login form
class _LoginFormConstants {
  static const double fieldSpacing = 16.0;
  static const double buttonTopSpacing = 24.0;
  static const double buttonPadding = 16.0;
  static const double submitFontSize = 16.0;
  static const double loadingIndicatorSize = 20.0;
  static const double loadingStrokeWidth = 2.0;
  static const int minimumPasswordLength = 6;
  static const String emailPattern = '@';
}

/// UI strings for login form
class _LoginFormStrings {
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String submitButtonText = 'Sign In';
  static const String emailRequiredError = 'Email is required';
  static const String emailInvalidError = 'Enter a valid email';
  static const String passwordRequiredError = 'Password is required';
  static const String passwordTooShortError =
      'Password must be at least ${_LoginFormConstants.minimumPasswordLength} characters';
}

/// Handles user input for authentication
/// Single Responsibility: Collect and validate login credentials
class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;
  final bool isLoading;

  const LoginForm({super.key, required this.onSubmit, this.isLoading = false});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      widget.onSubmit(_emailController.text.trim(), _passwordController.text);
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: _emailController, enabled: !widget.isLoading),
          const Gap(_LoginFormConstants.fieldSpacing),
          _PasswordField(
            controller: _passwordController,
            isVisible: _isPasswordVisible,
            onToggleVisibility: _togglePasswordVisibility,
            onSubmit: _submitForm,
            enabled: !widget.isLoading,
          ),
          const Gap(_LoginFormConstants.buttonTopSpacing),
          _SubmitButton(onPressed: _submitForm, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}

/// Email input field with validation
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _EmailField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: _LoginFormStrings.emailLabel,
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      validator: _validateEmail,
    );
  }

  String? _validateEmail(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return _LoginFormStrings.emailRequiredError;
    }

    if (!trimmedValue.contains(_LoginFormConstants.emailPattern)) {
      return _LoginFormStrings.emailInvalidError;
    }

    return null;
  }
}

/// Password input field with visibility toggle
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;
  final bool enabled;

  const _PasswordField({
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onSubmit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      textInputAction: TextInputAction.done,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: _LoginFormStrings.passwordLabel,
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        suffixIcon: _VisibilityToggle(
          isVisible: isVisible,
          onToggle: onToggleVisibility,
        ),
      ),
      validator: _validatePassword,
      onFieldSubmitted: (_) => onSubmit(),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _LoginFormStrings.passwordRequiredError;
    }

    if (value.length < _LoginFormConstants.minimumPasswordLength) {
      return _LoginFormStrings.passwordTooShortError;
    }

    return null;
  }
}

/// Password visibility toggle button
class _VisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggle;

  const _VisibilityToggle({required this.isVisible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
      onPressed: onToggle,
    );
  }
}

/// Submit button with loading state
class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _SubmitButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(_LoginFormConstants.buttonPadding),
      ),
      child: isLoading
          ? const _LoadingIndicator()
          : const Text(
              _LoginFormStrings.submitButtonText,
              style: TextStyle(fontSize: _LoginFormConstants.submitFontSize),
            ),
    );
  }
}

/// Loading spinner widget
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _LoginFormConstants.loadingIndicatorSize,
      width: _LoginFormConstants.loadingIndicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: _LoginFormConstants.loadingStrokeWidth,
      ),
    );
  }
}
