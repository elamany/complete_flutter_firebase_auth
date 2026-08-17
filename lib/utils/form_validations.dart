String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  String? validateDisplayName(String? value) {
    final displayName = value?.trim() ?? '';

    if (displayName.isEmpty) {
      return 'Display name is required.';
    }

    if (displayName.length < 2) {
      return 'Display name must be at least 2 characters.';
    }

    if (displayName.length > 50) {
      return 'Display name must be 50 characters or less.';
    }

    return null;
  }