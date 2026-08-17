import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_firebase_auth/features/user/providers/user_provider.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/change_password_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/delete_account_screen.dart';
import 'package:flutter_firebase_auth/screens/auth_and_profile/edit_profile_screen.dart';
import 'package:flutter_firebase_auth/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref
      .read(authControllerProvider.notifier)
      .signOut();

  if (!context.mounted) {
    return;
  }

  final authState = ref.read(authControllerProvider);

  if (authState.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          authState.error.toString(),
        ),
      ),
    );

    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);
    final firebaseUser = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final hasPasswordProvider =
    firebaseUser?.providerData.any(
          (provider) =>
              provider.providerId ==
              'password',
        ) ??
        false;

final hasGoogleProvider =
    firebaseUser?.providerData.any(
          (provider) =>
              provider.providerId ==
              'google.com',
        ) ??
        false;

    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load your profile.\n\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (user) {
            if (user == null || firebaseUser == null) {
              return Column(
                children: [
                  const Center(
                    child: Text(
                      'Your profile could not be found.',
                    ),
                  ),
                  SizedBox(height: 50,),
                  SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _signOut(
                            context,
                            ref,
                          ),
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text('Sign out'),
                  ),
                ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 42,
                    child: Text(
                      _initials(user.displayName),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : 'User',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    user.email,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                        ),
                        title: const Text(
                          'Display name',
                        ),
                        subtitle: Text(
                          user.displayName?.isNotEmpty == true
                              ? user.displayName!
                              : 'Not set',
                        ),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                        ),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

Card(
  child: Column(
    children: [
      const ListTile(
        leading: Icon(
          Icons.login_outlined,
        ),
        title: Text('Sign-in methods'),
      ),

      const Divider(height: 1),

      if (hasGoogleProvider)
        const ListTile(
          leading: Icon(
            Icons.account_circle_outlined,
          ),
          title: Text('Google'),
          trailing: Icon(
            Icons.check_circle_outline,
          ),
        ),

      if (hasPasswordProvider)
        const ListTile(
          leading: Icon(
            Icons.password_outlined,
          ),
          title: Text('Email & Password'),
          trailing: Icon(
            Icons.check_circle_outline,
          ),
        ),
    ],
  ),
),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const EditProfileScreen(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit profile'),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
                  icon: const Icon(
                    Icons.lock_outline,
                  ),
                  label: const Text('Change password'),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _signOut(
                            context,
                            ref,
                          ),
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text('Sign out'),
                  ),
                ),

                const SizedBox(height: 32),

                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DeleteAccountScreen(),
                            ),
                          );
                        },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text(
                    'Delete account',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _initials(String? displayName) {
    final name = displayName?.trim() ?? '';

    if (name.isEmpty) {
      return '?';
    }

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (
      parts.first.substring(0, 1) +
      parts.last.substring(0, 1)
    ).toUpperCase();
  }
}