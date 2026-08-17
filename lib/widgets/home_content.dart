import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/login_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/profile_screen.dart';

class HomeContent extends StatelessWidget {
  final bool isLoggedIn;
  final String? displayName;

  const HomeContent({
    super.key,
    required this.isLoggedIn,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final greetingName =
        displayName == null || displayName!.isEmpty
            ? 'there'
            : displayName!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLoggedIn
                  ? 'Welcome, $greetingName!'
                  : 'Welcome!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 24),

            if (isLoggedIn)
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
              )
            else
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginScreen(),
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