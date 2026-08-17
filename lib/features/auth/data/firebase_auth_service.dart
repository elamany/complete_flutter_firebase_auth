import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
bool _googleInitialized = false;
  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges();
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User _requireCurrentUser() {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-logged-in',
        message: 'No user is currently logged in.',
      );
    }

    return user;
  }

  // ============================================================
  // PROVIDERS
  // ============================================================

  bool hasProvider(String providerId) {
    final user = _requireCurrentUser();

    return user.providerData.any(
      (provider) => provider.providerId == providerId,
    );
  }

  bool get hasPasswordProvider {
    return hasProvider(EmailAuthProvider.PROVIDER_ID);
  }

  bool get hasGoogleProvider {
    return hasProvider(GoogleAuthProvider.PROVIDER_ID);
  }

  // ============================================================
  // EMAIL / PASSWORD
  // ============================================================

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) {
    return firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================
  
  Future<void> _initializeGoogleSignIn() async {
  if (_googleInitialized) {
    return;
  }

  await GoogleSignIn.instance.initialize();

  _googleInitialized = true;
}

  Future<UserCredential> signInWithGoogle() async {
  await _initializeGoogleSignIn();

  final googleUser =
      await GoogleSignIn.instance.authenticate();

  final googleAuthentication =
      googleUser.authentication;

  final idToken =
      googleAuthentication.idToken;

  if (idToken == null) {
    throw FirebaseAuthException(
      code: 'google-authentication-failed',
      message: 'Google authentication failed.',
    );
  }

  final credential =
      GoogleAuthProvider.credential(
    idToken: idToken,
  );

  return firebaseAuth.signInWithCredential(
    credential,
  );
}

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    await firebaseAuth.signOut();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Firebase sign-out already completed.
      // Google local session cleanup is best-effort.
    }
  }

  // ============================================================
  // PASSWORD RESET EMAIL
  // ============================================================

  Future<void> sendPasswordResetEmail(String email) {
    return firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<void> sendEmailVerification() async {
    final user = _requireCurrentUser();

    if (user.emailVerified) {
      return;
    }

    await user.sendEmailVerification();
  }

  Future<bool> refreshEmailVerification() async {
    final user = _requireCurrentUser();

    await user.reload();

    final refreshedUser = firebaseAuth.currentUser;

    return refreshedUser?.emailVerified ?? false;
  }

  // ============================================================
  // UPDATE DISPLAY NAME
  // ============================================================

  Future<void> updateUserName(String newUserName) {
    final user = _requireCurrentUser();

    return user.updateDisplayName(newUserName.trim());
  }

  // ============================================================
  // LINK PASSWORD TO CURRENT ACCOUNT
  // ============================================================

  Future<UserCredential> linkPasswordCredential(String password) async {
    final user = _requireCurrentUser();

    final email = user.email;

    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-email-missing',
        message: 'The current user does not have an email address.',
      );
    }

    if (hasPasswordProvider) {
      throw FirebaseAuthException(
        code: 'provider-already-linked',
        message: 'Email and password are already linked to this account.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    return user.linkWithCredential(credential);
  }

  // ============================================================
  // LINK GOOGLE TO CURRENT ACCOUNT
  // ============================================================

  Future<void> linkGoogleCredential() async {
    final user = _requireCurrentUser();

    if (hasGoogleProvider) {
      throw FirebaseAuthException(
        code: 'provider-already-linked',
        message: 'Google is already linked to this account.',
      );
    }

    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();

    final googleAuthentication = googleUser.authentication;

    final idToken = googleAuthentication.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'google-authentication-failed',
        message: 'Google authentication failed.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await user.linkWithCredential(credential);
  }

  // ============================================================
  // UPDATE PASSWORD
  // ============================================================

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _requireCurrentUser();

    if (!hasPasswordProvider) {
      throw FirebaseAuthException(
        code: 'password-provider-not-linked',
        message:
            'Email and password authentication is not enabled for this account.',
      );
    }

    await _reauthenticateWithPassword(user, currentPassword);

    await user.updatePassword(newPassword);
  }

  // ============================================================
  // UPDATE PASSWORD AFTER FORGOT PASSWORD
  // ============================================================
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return firebaseAuth.confirmPasswordReset(
      code: code,
      newPassword: newPassword,
    );
  }

  // ============================================================
  // UPDATE PASSWORD AFTER GOOGLE REAUTHENTICATION
  // ============================================================

  Future<void> updatePasswordAfterGoogleReauthentication(
    String newPassword,
  ) async {
    final user = _requireCurrentUser();

    await _reauthenticateWithGoogle(user);

    await user.updatePassword(newPassword);
  }

  // ============================================================
  // GENERIC REAUTHENTICATION
  // ============================================================

  Future<void> reauthenticate({String? currentPassword}) async {
    final user = _requireCurrentUser();

    if (hasPasswordProvider) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw FirebaseAuthException(
          code: 'password-required',
          message: 'Your current password is required.',
        );
      }

      await _reauthenticateWithPassword(user, currentPassword);

      return;
    }

    if (hasGoogleProvider) {
      await _reauthenticateWithGoogle(user);

      return;
    }

    throw FirebaseAuthException(
      code: 'unsupported-provider',
      message: 'This authentication provider is not supported.',
    );
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount({String? currentPassword}) async {
    final user = _requireCurrentUser();

    // Firebase requires recent authentication
    // for sensitive operations such as account deletion.
    await reauthenticate(currentPassword: currentPassword);

    await user.delete();

    // Best-effort local Google session cleanup.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Firebase account deletion already completed.
    }
  }

  // ============================================================
  // PRIVATE: PASSWORD REAUTHENTICATION
  // ============================================================

  Future<void> _reauthenticateWithPassword(User user, String password) async {
    final email = user.email;

    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'email-not-available',
        message: 'This account does not have an email address.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  // ============================================================
  // PRIVATE: GOOGLE REAUTHENTICATION
  // ============================================================

  Future<void> _reauthenticateWithGoogle(User user) async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();

    final googleAuthentication = googleUser.authentication;

    final idToken = googleAuthentication.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'google-authentication-failed',
        message: 'Google authentication failed.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await user.reauthenticateWithCredential(credential);
  }
}
