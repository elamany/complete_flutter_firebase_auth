import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_firebase_auth/features/user/providers/user_provider.dart';
import 'package:flutter_firebase_auth/widgets/home_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final appUserAsync = ref.watch(appUserProvider);

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
          data: (firebaseUser) {
            if (firebaseUser == null) {
              return const HomeContent(
                isLoggedIn: false,
              );
            }

            return appUserAsync.when(
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (error, stackTrace) {
                return Center(
                  child: Text(
                    'Unable to load your profile.\n$error',
                    textAlign: TextAlign.center,
                  ),
                );
              },
              data: (appUser) {
                final displayName =
                    appUser?.displayName?.trim();

                return HomeContent(
                  isLoggedIn: true,
                  displayName: displayName,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
