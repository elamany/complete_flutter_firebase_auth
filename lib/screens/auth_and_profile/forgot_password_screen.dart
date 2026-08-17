import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_firebase_auth/utils/form_validations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(
          _emailController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);

    if (authState.hasError) {
      return;
    }

    setState(() {
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot password'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),

              Icon(
                Icons.lock_reset,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              Text(
                _emailSent
                    ? 'Check your email'
                    : 'Reset your password',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 12),

              Text(
                _emailSent
                    ? 'We sent a password reset link to '
                        '${_emailController.text.trim()}. '
                        'Check your inbox and follow the instructions.'
                    : 'Enter the email address associated with '
                        'your account and we will send you a '
                        'password reset link.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 32),

              if (!_emailSent) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      _sendResetEmail();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: validateEmail,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        isLoading ? null : _sendResetEmail,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send reset email',
                          ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to sign in'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}