import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/models/auth_status.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_status_provider.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/complete_profile_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/login_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/verify_email_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.authenticated,
  });

  final Widget authenticated;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final status = ref.watch(authStatusProvider);

    switch (status) {
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case AuthStatus.unauthenticated:
        return const LoginScreen();

      case AuthStatus.emailNotVerified:
        return const VerifyEmailScreen();

      case AuthStatus.profileIncomplete:
        return const CompleteProfileScreen();

      case AuthStatus.authenticated:
        return authenticated;

      case AuthStatus.error:
        return const Scaffold(
          body: Center(
            child: Text(
              'Unable to load your account.',
            ),
          ),
        );
    }
  }
}