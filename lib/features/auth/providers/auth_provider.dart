import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/features/auth/data/firebase_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(
    firebaseAuthServiceProvider,
  );

  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});