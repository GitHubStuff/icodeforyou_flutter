// form_validators.dart
/// Form validation utilities
/// Single Responsibility: Only handles validation logic
library;

const _minimumPasswordLength = 6;

class FormValidators {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < _minimumPasswordLength) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
