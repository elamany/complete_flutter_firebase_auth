import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

class AuthExceptionMapper {
  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return _mapFirebaseAuthException(error);
    }

    return const AppException(
      code: 'unknown',
      message: 'Something went wrong. Please try again.',
    );
  }

  static AppException _mapFirebaseAuthException(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return const AppException(
          code: 'invalid-credentials',
          message: 'Invalid email or password.',
        );

      case 'user-not-found':
        return const AppException(
          code: 'user-not-found',
          message: 'No account was found with this email.',
        );

      case 'email-already-in-use':
        return const AppException(
          code: 'email-already-in-use',
          message: 'An account already exists with this email.',
        );

      case 'invalid-email':
        return const AppException(
          code: 'invalid-email',
          message: 'Please enter a valid email address.',
        );

      case 'weak-password':
        return const AppException(
          code: 'weak-password',
          message: 'Your password is too weak.',
        );

      case 'user-disabled':
        return const AppException(
          code: 'user-disabled',
          message: 'This account has been disabled.',
        );

      case 'too-many-requests':
        return const AppException(
          code: 'too-many-requests',
          message: 'Too many attempts. Please try again later.',
        );

      case 'network-request-failed':
        return const AppException(
          code: 'network-error',
          message: 'Please check your internet connection.',
        );

      case 'requires-recent-login':
        return const AppException(
          code: 'requires-recent-login',
          message: 'Please sign in again before performing this action.',
        );

      case 'user-not-logged-in':
        return const AppException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );

      case 'email-not-available':
        return const AppException(
          code: 'email-not-available',
          message: 'This account does not have an email address.',
        );

      case 'credential-already-in-use':
        return const AppException(
          code: 'credential-already-in-use',
          message: 'This credential is already associated with another user.',
        );

      case 'provider-already-linked':
        return const AppException(
          code: 'provider-already-linked',
          message: 'This sign-in method is already linked to your account.',
        );

      case 'account-exists-with-different-credential':
        return const AppException(
          code: 'account-exists-with-different-credential',
          message:
              'An account already exists with this email using a different sign-in method.',
        );

      case 'popup-closed-by-user':
      case 'canceled':
        return const AppException(
          code: 'sign-in-cancelled',
          message: 'Sign-in was cancelled.',
        );

      case 'operation-not-allowed':
        return const AppException(
          code: 'operation-not-allowed',
          message: 'This sign-in method is currently unavailable.',
        );

      case 'password-required':
        return const AppException(
          code: 'password-required',
          message: 'Your current password is required.',
        );

      case 'password-provider-not-linked':
        return const AppException(
          code: 'password-provider-not-linked',
          message:
              'Email and password authentication is not enabled for this account.',
        );

      case 'google-authentication-failed':
        return const AppException(
          code: 'google-authentication-failed',
          message: 'Google authentication failed. Please try again.',
        );

      case 'unsupported-provider':
        return const AppException(
          code: 'unsupported-provider',
          message: 'This authentication provider is not supported.',
        );

      default:
        return AppException(
          code: error.code,
          message:
              error.message ?? 'Authentication failed. Please try again.',
        );
    }
  }
}