import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/login_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SafeArea(
        child: authState.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Something went wrong.\n$error',
                textAlign: TextAlign.center,
              ),
            );
          },
          data: (user) {
            return _HomeContent(
              user: user,
            );
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final User? user;

  const _HomeContent({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;

    final displayName = user?.displayName?.trim();

    final greetingName = displayName == null ||
            displayName.isEmpty
        ? 'there'
        : displayName;

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