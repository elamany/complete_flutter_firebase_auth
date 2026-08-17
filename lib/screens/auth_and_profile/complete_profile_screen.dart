import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({
    super.key,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() {
    return _CompleteProfileScreenState();
  }
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    final user = ref.read(currentUserProvider);

    _displayNameController = TextEditingController(
      text: user?.displayName?.trim() ?? '',
    );

    _passwordController = TextEditingController();

    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _completeAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .completeGoogleAccount(
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);

    authState.whenOrNull(
      data: (_) {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  error.toString(),
                ),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete your account',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),

              const Text(
                'Almost there!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'We found your Google account. '
                'Create a password so you can also sign in '
                'with your email and password.',
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // DISPLAY NAME
              // ------------------------------------------------

              TextFormField(
                controller: _displayNameController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Please enter your name.';
                  }

                  if (name.length < 2) {
                    return 'Name must be at least 2 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // EMAIL
              // ------------------------------------------------

              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(
                    currentUserProvider,
                  );

                  return TextFormField(
                    initialValue: user?.email ?? '',
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // PASSWORD
              // ------------------------------------------------

              TextFormField(
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                  final password = value ?? '';

                  if (password.isEmpty) {
                    return 'Please enter a password.';
                  }

                  if (password.length < 8) {
                    return 'Password must be at least 8 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // CONFIRM PASSWORD
              // ------------------------------------------------

              TextFormField(
                controller:
                    _confirmPasswordController,
                enabled: !isLoading,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!isLoading) {
                    _completeAccount();
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password.';
                  }

                  if (value !=
                      _passwordController.text) {
                    return 'Passwords do not match.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // CONTINUE BUTTON
              // ------------------------------------------------

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed:
                      isLoading ? null : _completeAccount,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}