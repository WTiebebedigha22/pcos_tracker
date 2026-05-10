class Validators {
  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  }

  // Password Validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Required Field
  static String? validateRequired(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Number Validator
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }

    final number = double.tryParse(value);

    if (number == null) {
      return 'Enter a valid number';
    }

    return null;
  }
}
class Validators {
  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  }

  // Password Validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Required Field
  static String? validateRequired(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Number Validator
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }

    final number = double.tryParse(value);

    if (number == null) {
      return 'Enter a valid number';
    }

    return null;
  }
}