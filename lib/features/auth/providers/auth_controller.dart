import 'package:flutter_firebase_auth/features/auth/data/firebase_auth_service.dart';
import 'package:flutter_firebase_auth/features/user/data/user_firestore_service.dart';
import 'package:flutter_firebase_auth/features/user/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_provider.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  FirebaseAuthService get _authService {
    return ref.read(firebaseAuthServiceProvider);
  }

  UserFirestoreService get _userService {
    return ref.read(userFirestoreServiceProvider);
  }

  @override
  Future<void> build() async {}

  // ============================================================
  // EMAIL/PASSWORD SIGN UP
  // ============================================================

  Future<void> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final credential =
          await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      final user = credential.user;

      if (user == null) {
        throw StateError(
          'User creation succeeded but no user was returned.',
        );
      }

      await _authService.updateUserName(
        displayName,
      );

      await _userService.createUserIfNotExists(
        uid: user.uid,
        email: user.email ?? email,
        displayName: displayName.trim(),
      );

      await _authService.sendEmailVerification();
    });
  }

  // ============================================================
  // EMAIL/PASSWORD SIGN IN
  // ============================================================

  Future<void> signIn(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
    });
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final credential =
          await _authService.signInWithGoogle();

      final user = credential.user;

      if (user == null) {
        throw StateError(
          'Google sign-in succeeded but no Firebase user was returned.',
        );
      }

      await _userService.createUserIfNotExists(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    });
  }

  Future<void> createPasswordForGoogleUser(
    String password,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.linkPasswordCredential(
        password,
      );
    });
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.signOut();
    });
  }

  // ============================================================
  // PASSWORD RESET EMAIL
  // ============================================================

  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.sendPasswordResetEmail(
        email,
      );
    });
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<void> sendEmailVerification() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.sendEmailVerification();
    });
  }

  // ============================================================
  // REFRESH EMAIL VERIFICATION STATUS
  // ============================================================

  Future<bool> refreshEmailVerification() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _authService.refreshEmailVerification(),
    );

    state = result;

    return result.value ?? false;
  }

  // ============================================================
  // UPDATE PASSWORD in profile/account setting
  // ============================================================

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.updatePassword(
        currentPassword,
        newPassword,
      );
    });
  }

  // ============================================================
  // UPDATE PASSWORD in forgot password reset
  // ============================================================

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    });
  }

  // ============================================================
  // UPDATE USER NAME
  // ============================================================

  Future<void> updateUserName(
    String newUserName,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = _authService.currentUser;

      if (user == null) {
        throw StateError(
          'No user is currently logged in.',
        );
      }

      await _authService.updateUserName(
        newUserName,
      );

      await _userService.updateProfile(
        uid: user.uid,
        displayName: newUserName.trim(),
      );
    });
  }

  // ============================================================
  // LINK PASSWORD TO GOOGLE ACCOUNT
  // ============================================================

  Future<void> linkPasswordCredential(
    String password,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.linkPasswordCredential(
        password,
      );
    });
  }

  // ============================================================
  // COMPLETE GOOGLE ACCOUNT
  // ============================================================

  Future<void> completeGoogleAccount({
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = _authService.currentUser;

      if (user == null) {
        throw StateError(
          'No user is currently logged in.',
        );
      }

      // --------------------------------------------------------
      // 1. Link password if it is not already linked.
      // --------------------------------------------------------

      if (!_authService.hasPasswordProvider) {
        await _authService.linkPasswordCredential(
          password,
        );
      }

      // --------------------------------------------------------
      // 2. Update Firebase Auth display name.
      // --------------------------------------------------------

      await _authService.updateUserName(
        displayName,
      );

      // --------------------------------------------------------
      // 3. Mark the Firestore profile as completed.
      // --------------------------------------------------------

      await _userService.updateProfile(
        uid: user.uid,
        displayName: displayName.trim(),
      );
    });
  }

  // ============================================================
  // REAUTHENTICATE
  // ============================================================

  Future<void> reauthenticate({
    String? currentPassword,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _authService.reauthenticate(
        currentPassword: currentPassword,
      );
    });
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount({
    String? currentPassword,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = _authService.currentUser;

      if (user == null) {
        throw StateError(
          'No user is currently logged in.',
        );
      }

      final uid = user.uid;

      await _authService.reauthenticate(
        currentPassword: currentPassword,
      );

      await _userService.deleteUser(uid);

      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Firebase account deletion already completed.
      }

    });
  }


}