import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState
    extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;

  int _secondsRemaining = 0;

  bool get _canResend => _secondsRemaining == 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .sendEmailVerification();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);

    if (authState.hasError) {
      return;
    }

    _startCooldown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Verification email sent. Check your inbox.',
        ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    final isVerified = await ref
        .read(authControllerProvider.notifier)
        .refreshEmailVerification();

    if (!mounted) {
      return;
    }

    if (isVerified) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your email is not verified yet. '
          'Please check your inbox.',
        ),
      ),
    );
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify your email'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),

              Icon(
                Icons.mark_email_unread_outlined,
                size: 72,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),

              const SizedBox(height: 24),

              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 16),

              Text(
                'We sent a verification link to your email '
                'address. Open the email and click the link '
                'to verify your account.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed:
                      isLoading ? null : _checkVerification,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'I verified my email',
                        ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed:
                      isLoading || !_canResend
                          ? null
                          : _resendVerificationEmail,
                  child: _secondsRemaining > 0
                      ? Text(
                          'Resend email ($_secondsRemaining s)',
                        )
                      : const Text(
                          'Resend verification email',
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Did not receive the email? '
                'Check your spam or junk folder.',
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
}