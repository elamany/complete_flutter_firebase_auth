import 'package:flutter_firebase_auth/features/auth/models/auth_status.dart';
import 'package:flutter_firebase_auth/features/user/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  if (authState.isLoading) {
    return AuthStatus.loading;
  }

  if (authState.hasError) {
    return AuthStatus.error;
  }

  final firebaseUser = authState.value;

  if (firebaseUser == null) {
    return AuthStatus.unauthenticated;
  }

  final appUserState = ref.watch(appUserProvider);

  if (appUserState.isLoading) {
    return AuthStatus.loading;
  }

  if (appUserState.hasError) {
    return AuthStatus.error;
  }

  final appUser = appUserState.value;

  if (appUser == null) {
    return AuthStatus.profileIncomplete;
  }

  final hasPasswordProvider = firebaseUser.providerData.any(
    (provider) => provider.providerId == 'password',
  );

  if (hasPasswordProvider && !firebaseUser.emailVerified) {
    return AuthStatus.emailNotVerified;
  }

  if (!appUser.profileCompleted) {
    return AuthStatus.profileIncomplete;
  }

  return AuthStatus.authenticated;
});