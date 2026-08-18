import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_firebase_auth/screens/home_screen.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({
    super.key,
  });

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState
    extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();

    if (!confirmed || !mounted) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .deleteAccount(
          currentPassword: _passwordController.text,
        );

    final authState = ref.read(authControllerProvider);

    if (authState.hasError) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete account?',
          ),
          content: const Text(
            'This action permanently deletes your account '
            'and profile data. This cannot be undone.\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete account',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final firebaseUser = ref.watch(currentUserProvider);

    final isLoading = authState.isLoading;

    final hasPasswordProvider =
        firebaseUser?.providerData.any(
              (provider) =>
                  provider.providerId == 'password',
            ) ??
            false;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _getErrorMessage(error),
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delete account',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 72,
              ),

              const SizedBox(height: 24),

              Text(
                'Delete your account',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 12),

              const Text(
                'Deleting your account permanently removes '
                'your account and profile data.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              if (hasPasswordProvider) ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      _deleteAccount();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Current password is required.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),
              ] else ...[
                const Text(
                  'Your account uses Google authentication. '
                  'You will be asked to authenticate with Google '
                  'before the account is deleted.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed:
                      isLoading ? null : _deleteAccount,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete my account',
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('wrong-password')) {
      return 'Your current password is incorrect.';
    }

    if (message.contains('requires-recent-login')) {
      return 'Please sign in again before deleting your account.';
    }

    if (message.contains('user-not-logged-in')) {
      return 'No user is currently signed in.';
    }

    return message;
  }
}