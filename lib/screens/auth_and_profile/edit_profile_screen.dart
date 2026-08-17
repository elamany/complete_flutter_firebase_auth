import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_controller.dart';
import 'package:flutter_firebase_auth/features/user/providers/user_provider.dart';
import 'package:flutter_firebase_auth/utils/form_validations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _initializeFromUser(String? displayName) {
    if (_initialized) {
      return;
    }

    _displayNameController.text = displayName ?? '';
    _initialized = true;
  }

  

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final displayName =
        _displayNameController.text.trim();

    await ref
        .read(authControllerProvider.notifier)
        .updateUserName(displayName);

    if (!mounted) {
      return;
    }

    final authState =
        ref.read(authControllerProvider);

    if (authState.hasError) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully.'),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(appUserProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
      );
    });

    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
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
            if (user == null) {
              return const Center(
                child: Text(
                  'No profile found.',
                ),
              );
            }

            _initializeFromUser(user.displayName);

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Edit your profile',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Update your display name.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _displayNameController,
                    enabled: !isLoading,
                    textInputAction:
                        TextInputAction.done,
                    textCapitalization:
                        TextCapitalization.words,
                    maxLength: 50,
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        _saveProfile();
                      }
                    },
                    decoration:
                        const InputDecoration(
                      labelText: 'Display name',
                      hintText: 'Your name',
                      border: OutlineInputBorder(),
                    ),
                    validator:(value) => validateDisplayName(value),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          isLoading ? null : _saveProfile,
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
                              'Save changes',
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}