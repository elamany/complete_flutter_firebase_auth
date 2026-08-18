import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/login_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/profile_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.isLoggedIn,
    this.displayName,
  });

  final bool isLoggedIn;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return _SignedOutContent();
    }

    final name = displayName?.trim();

    final greetingName =
        name == null || name.isEmpty
            ? 'there'
            : name;

    return _SignedInContent(
      greetingName: greetingName,
    );
  }
}

class _SignedOutContent extends StatelessWidget {
  const _SignedOutContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInContent extends StatelessWidget {
  const _SignedInContent({
    required this.greetingName,
  });

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $greetingName!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProfileScreen(),
                  ),
                );
              },
              child: const Text('My Profile'),
            ),
          ],
        ),
      ),
    );
  }
}