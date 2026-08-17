import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/features/auth/providers/auth_provider.dart';
import 'package:flutter_firebase_auth/features/user/data/user_firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_provider.dart';

final userControllerProvider =
    AsyncNotifierProvider<UserController, void>(
  UserController.new,
);

class UserController extends AsyncNotifier<void> {
  UserFirestoreService get _userService {
    return ref.read(userFirestoreServiceProvider);
  }

  User? get _firebaseUser {
    return ref.read(firebaseAuthServiceProvider).currentUser;
  }

  @override
  FutureOr<void> build() {}

  Future<void> createUserProfileIfNeeded() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = _firebaseUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }

      final email = user.email;

      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-email-missing',
          message: 'Authenticated user has no email address.',
        );
      }

      await _userService.createUserIfNotExists(
        uid: user.uid,
        email: email,
        displayName: user.displayName,
      );
    });
  }

  Future<void> completeProfile({
    required String displayName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = _firebaseUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }

      await _userService.updateProfile(
        uid: user.uid,
        displayName: displayName,
      );

      await user.updateDisplayName(displayName);
    });
  }
}