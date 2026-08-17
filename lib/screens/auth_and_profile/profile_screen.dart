import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load your profile.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          data: (user) {
            if (user == null) {
              return const _NotLoggedIn();
            }

            return _ProfileContent(
              user: user,
            );
          },
        ),
      ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'You are not signed in.',
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final User user;

  const _ProfileContent({
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController =
        ref.read(authControllerProvider.notifier);

    final displayName = user.displayName?.trim();

    final email = user.email?.trim();

    final hasGoogle = user.providerData.any(
      (provider) =>
          provider.providerId ==
          GoogleAuthProvider.PROVIDER_ID,
    );

    final hasPassword = user.providerData.any(
      (provider) =>
          provider.providerId ==
          EmailAuthProvider.PROVIDER_ID,
    );

    final isVerified = user.emailVerified;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),

        CircleAvatar(
          radius: 48,
          child: user.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    user.photoURL!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 48,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 48,
                ),
        ),

        const SizedBox(height: 16),

        Text(
          displayName == null || displayName.isEmpty
              ? 'No name'
              : displayName,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall,
        ),

        const SizedBox(height: 8),

        Text(
          email ?? 'No email address',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),

        const SizedBox(height: 24),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  isVerified
                      ? Icons.verified
                      : Icons.warning_amber_rounded,
                ),
                title: const Text('Email verification'),
                subtitle: Text(
                  isVerified
                      ? 'Email verified'
                      : 'Email not verified',
                ),
                trailing: isVerified
                    ? null
                    : const Icon(
                        Icons.chevron_right,
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.email_outlined,
                ),
                title: const Text('Email & password'),
                subtitle: Text(
                  hasPassword
                      ? 'Connected'
                      : 'Not connected',
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.g_mobiledata,
                ),
                title: const Text('Google'),
                subtitle: Text(
                  hasGoogle
                      ? 'Connected'
                      : 'Not connected',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        FilledButton.tonal(
          onPressed: () {
            _showComingSoon(
              context,
              'Edit profile',
            );
          },
          child: const Text('Edit profile'),
        ),

        const SizedBox(height: 12),

        if (hasPassword)
          OutlinedButton(
            onPressed: () {
              _showComingSoon(
                context,
                'Change password',
              );
            },
            child: const Text('Change password'),
          ),

        if (!hasPassword)
          OutlinedButton(
            onPressed: () {
              _showComingSoon(
                context,
                'Create password',
              );
            },
            child: const Text('Create password'),
          ),

        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () {
            _showComingSoon(
              context,
              hasGoogle
                  ? 'Google is already connected'
                  : 'Connect Google',
            );
          },
          child: Text(
            hasGoogle
                ? 'Google connected'
                : 'Connect Google',
          ),
        ),

        const SizedBox(height: 24),

        TextButton(
          onPressed: () async {
            await authController.signOut();

            if (!context.mounted) {
              return;
            }

            Navigator.of(context).pop();
          },
          child: const Text('Sign out'),
        ),

        const SizedBox(height: 8),

        TextButton(
          onPressed: () {
            _showComingSoon(
              context,
              'Delete account',
            );
          },
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete account'),
        ),
      ],
    );
  }

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature screen will be added next.',
        ),
      ),
    );
  }
}