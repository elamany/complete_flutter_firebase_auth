import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_firebase_auth/utils/form_validations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final firebaseUser = ref.read(currentUserProvider);

    if (firebaseUser == null) {
      return;
    }

    final hasPasswordProvider = firebaseUser.providerData.any(
      (provider) =>
          provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );

    if (hasPasswordProvider) {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );
    } else {
      await ref
          .read(authControllerProvider.notifier)
          .linkPasswordCredential(
            _newPasswordController.text,
          );
    }

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);

    if (authState.hasError) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasPasswordProvider
              ? 'Password changed successfully.'
              : 'Password created successfully.',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final firebaseUser = ref.watch(currentUserProvider);

    final isLoading = authState.isLoading;

    final hasPasswordProvider = firebaseUser?.providerData.any(
          (provider) =>
              provider.providerId == EmailAuthProvider.PROVIDER_ID,
        ) ??
        false;

        debugPrint('hasPasswordProvider:---> $hasPasswordProvider');

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
        title: Text(
          hasPasswordProvider
              ? 'Change password'
              : 'Create password',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.lock_outline,
                size: 72,
              ),

              const SizedBox(height: 24),

              Text(
                hasPasswordProvider
                    ? 'Change your password'
                    : 'Create a password',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 12),

              Text(
                hasPasswordProvider
                    ? 'Enter your current password and choose a new password.'
                    : 'Your account currently uses Google Sign-In. '
                      'Create a password to also sign in with your email and password.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 32),

              if (hasPasswordProvider) ...[
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword =
                              !_obscureCurrentPassword;
                        });
                      },
                      icon: Icon(
                        _obscureCurrentPassword
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

                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'New password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword =
                            !_obscureNewPassword;
                      });
                    },
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: ((value) =>  validatePassword(value)),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onFieldSubmitted: (_) {
                  if (!isLoading) {
                    _submit();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: ((value) => validateConfirmPassword(value, _newPasswordController.text)),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          hasPasswordProvider
                              ? 'Change password'
                              : 'Create password',
                        ),
                ),
              ),

              const SizedBox(height: 16),

              if (!hasPasswordProvider)
                Text(
                  'After creating a password, you can sign in '
                  'with either Google or your email and password.',
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
      return 'Please sign in again before changing your password.';
    }

    if (message.contains('provider-already-linked')) {
      return 'A password is already linked to this account.';
    }

    if (message.contains('user-not-logged-in')) {
      return 'No user is currently signed in.';
    }

    if (message.contains('email-already-in-use')) {
      return 'This email address is already associated with another account.';
    }

    return message;
  }
}
