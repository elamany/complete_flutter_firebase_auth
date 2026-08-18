# Flutter Firebase Authentication

A production-oriented Flutter authentication project built with **Firebase Authentication, Cloud Firestore, and Riverpod**.

The project supports email/password authentication, Google Sign-In, email verification, password reset, password creation for Google accounts, profile management, and account deletion.

## Features

### Authentication

- Email/password registration
- Email/password sign in
- Google Sign-In
- Email verification
- Forgot password / password reset
- Password creation for Google-only accounts
- Change existing password
- Sign out
- Re-authentication for sensitive operations
- Account deletion with confirmation
- Support for accounts using:
  - Google authentication
  - Email/password authentication
  - Both Google and email/password authentication

### User Profile

- Firestore user profiles
- Display name
- Email address
- Profile completion status
- Edit profile
- Real-time profile updates
- Profile state management with Riverpod

### Home

- Shows a sign-in button when the user is logged out
- Shows the user's display name when logged in
- Provides access to the profile page
- Automatically updates authentication state
- Automatically reflects profile changes

## Authentication Flow

### Email/Password Registration

```text
Register
   ↓
Create Firebase Authentication user
   ↓
Create Firestore user document
   ↓
Send verification email
   ↓
Verify email
```

The Firestore user document is stored using the Firebase Authentication UID:

```text
users/{uid}
```

Example:

```json
{
  "email": "user@example.com",
  "displayName": "John",
  "profileCompleted": false,
  "createdAt": "server timestamp"
}
```

### Google Sign-In Flow

Google users can initially create an account using Google authentication.

```text
Google Sign-In
      ↓
Firebase Authentication
      ↓
Create Firestore profile
      ↓
Complete profile
```

A Google-only account can later create a password.

**Google-only account**  
The user sees:
- Create password
- New password
- Confirm password

No current password is required because the account does not have a password credential yet.  
After creating the password, the account has both:
- `google.com`
- `password`

The same Firebase UID is retained.

**Account with password already linked**  
After a password has been created, the Change Password screen becomes:
- Current password
- New password
- Confirm password

The current password is required before changing the password.

### Password Management

The application distinguishes between two password operations.

1. **Create Password**  
   Used when a Google account does not have a password provider.
   ```text
   Google account
        ↓
   Create password
        ↓
   linkPasswordCredential()
   ```

2. **Change Password**  
   Used when the account already has an email/password provider.
   ```text
   Current password
           ↓
   Re-authenticate
           ↓
   New password
           ↓
   Update password
   ```
   This prevents a user from changing a password without proving knowledge of the existing password.

### Forgot Password

Users can request a Firebase password-reset email.

```text
Forgot password
      ↓
Enter email
      ↓
Firebase sends reset email
      ↓
Firebase reset link
      ↓
New password
```

Firebase generates the password reset code and handles its validity and expiration.  
The reset code is not a permanent user identifier.

### Email Verification

New email/password users receive an email verification message.  
The application can refresh the Firebase user and check `emailVerified`.  
The verification flow is separate from password reset.

### Account Deletion

Account deletion requires confirmation to prevent accidental deletion.

For password accounts:
```text
Current password
       ↓
Re-authentication
       ↓
Confirmation dialog
       ↓
Delete Firebase account
```

For Google accounts, Google authentication is used for re-authentication.  
After deletion, the application returns to the Home screen and clears the authenticated user state.

## Firestore User Profile

User profiles are stored under:
```text
users/{uid}
```

The application uses the Firebase Authentication UID as the Firestore document ID.

### User Model

```dart
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final bool profileCompleted;
  final DateTime createdAt;
}
```

### Profile Fields
- `email`
- `displayName`
- `profileCompleted`
- `createdAt`

Example:

```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "profileCompleted": true,
  "createdAt": "server timestamp"
}
```

## State Management

The project uses Riverpod for application state management.  
Important providers include:

- `authStateProvider`
- `currentUserProvider`
- `authControllerProvider`
- `appUserProvider`
- `userFirestoreServiceProvider`
- `firebaseAuthServiceProvider`

### Firebase Authentication State

The application uses Firebase `userChanges()` rather than only `authStateChanges()`.  
This is important because Firebase user information can change while the user remains authenticated.  
For example, linking a password to a Google account changes `providerData` without necessarily changing the authentication state.

Using `userChanges()` allows the application to immediately detect changes such as:
- Provider linking
- Display name changes
- Email changes
- Other Firebase user updates
- Sign in
- Sign out

## Project Structure

```text
lib/
│
├── core/
│   └── firebase/
│       └── firebase_options.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── firebase_auth_service.dart
│   │   │
│   │   └── providers/
│   │       ├── auth_controller.dart
│   │       └── auth_provider.dart
│   │
│   └── user/
│       ├── data/
│       │   └── user_firestore_service.dart
│       │
│       ├── models/
│       │   └── app_user.dart
│       │
│       └── providers/
│           └── user_provider.dart
│
├── screens/
│   ├── auth_and_profile/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── verify_email_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── change_password_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── delete_account_screen.dart
│   │   └── complete_google_signup_screen.dart
│   │
│   └── home_screen.dart
│
├── utils/
│   └── form_validations.dart
│
├── widgets/
│   └── home_content.dart
│
└── main.dart
```

## Main Technologies

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Google Sign-In
- Riverpod

## Dependencies

The main packages used by the project include:

```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core:
  firebase_auth:
  cloud_firestore:
  flutter_riverpod:
  google_sign_in:
```

Use the versions defined in `pubspec.yaml` for the exact project configuration.

## Firebase Setup

Before running the application, configure Firebase for your Flutter project.

### 1. Create a Firebase project
Create a project in the Firebase Console.

### 2. Add your Android application
Register your Android application using the correct package name.

### 3. Configure Firebase for Flutter
Generate the Firebase configuration using FlutterFire CLI:

```bash
flutterfire configure
```

This generates the Firebase configuration used by:  
`lib/core/firebase/firebase_options.dart`

### 4. Enable Authentication providers
In Firebase Authentication, enable:
- Email/Password
- Google

### 5. Create Cloud Firestore
Create a Cloud Firestore database for the Firebase project.  
The application expects the default Firestore database: `(default)`

### 6. Configure Google Sign-In
For Android Google Sign-In, add the appropriate SHA-1 fingerprint to the Firebase Android application configuration.

You can obtain the debug signing report with:
```bash
cd android
./gradlew signingReport
```
*(On Windows: `cd android`, then `.\gradlew.bat signingReport`)*

Add the required SHA-1 fingerprint in:
- Firebase Console
- Project Settings
- Your apps
- Android app

Then download/update the Firebase Android configuration if required.

## Android Configuration

- The Android package name must match the package registered in Firebase.
- Make sure Firebase configuration is correctly generated for the Android application.
- For Google Sign-In, the SHA-1 fingerprint is particularly important. Without the correct SHA-1 configuration, Google Sign-In can fail with errors such as `GoogleSignInException code.canceled`.

## Firestore Security Rules

The application uses the authenticated Firebase UID as the Firestore user document ID.  
A basic security model is:
```text
users/{uid}
```

Users should only be allowed to read and modify their own profile.  
Example concept:
```javascript
request.auth.uid == uid
```

Do not deploy permissive Firestore rules such as allowing unrestricted reads and writes in a production application.

## Running the Project

Clone the repository:
```bash
git clone https://github.com/elamany/complete_flutter_firebase_auth.git
```

Enter the project directory:
```bash
cd flutter-firebase-auth
```

Install dependencies:
```bash
flutter pub get
```

Configure Firebase:
```bash
flutterfire configure
```

Run the application:
```bash
flutter run
```

## Important Firebase Files

Firebase configuration files contain project-specific configuration.  
Do not accidentally commit sensitive or environment-specific configuration files if your project setup requires them to remain private.

- FlutterFire generated configuration: `lib/core/firebase/firebase_options.dart`
- Android Firebase configuration: `android/app/google-services.json`

Make sure your repository strategy is appropriate for your Firebase project and deployment environment.

## Architecture

The application separates responsibilities into services, providers, controllers, models, screens, and reusable widgets.

- **Authentication service (`FirebaseAuthService`)**: Responsible for Firebase Authentication operations (Create account, Sign in, Google Sign-In, Sign out, Send verification email, Password reset, Update password, Link password credential, Re-authentication, Delete account, Update display name).
- **Authentication controller (`AuthController`)**: Responsible for coordinating UI actions with the authentication service, exposed through `authControllerProvider`.
- **User Firestore service (`UserFirestoreService`)**: Responsible for Firestore profile operations (Create user profile, Read user profile, Watch user profile, Update profile).
- **User provider (`appUserProvider`)**: Provides the Firestore profile reactively by watching the Firebase authentication user and then watching `users/{uid}`.

## Authentication and Profile Separation

Firebase Authentication and Firestore have separate responsibilities.

- **Firebase Authentication**: Stores authentication-related information (UID, Email, Authentication providers, Password credential, Email verification status).
- **Firestore**: Stores application-specific profile information (Display name, Profile completion, Created timestamp, Other application profile fields).

The Firebase UID connects the two systems:
```text
Firebase Auth UID ───> users/{uid}
```

## Security Considerations

- The project uses Firebase Authentication for identity management instead of storing passwords in Firestore.
- Passwords should never be stored manually in Firestore.
- Sensitive operations such as changing a password or deleting an account should require recent authentication when Firebase requires it.
- Password reset is handled through Firebase's password-reset mechanism rather than storing reset credentials in the application database.
- Firestore access should be protected with security rules so users cannot access another user's profile.

## Supported Account States

### 1. Email/Password (`password`)
User can:
- Sign in with email/password
- Change password
- Reset password
- Delete account

### 2. Google (`google.com`)
User can:
- Sign in with Google
- Create a password
- Delete account

### 3. Google + Password (`google.com`, `password`)
User can:
- Sign in with Google
- Sign in with email/password
- Change password
- Reset password
- Delete account

## Example User Journey

**New email user**  
`Create account` ➔ `Verify email` ➔ `Home` ➔ `Profile` ➔ `Edit profile`

**New Google user**  
`Google Sign-In` ➔ `Complete profile` ➔ `Create password (optional)` ➔ `Profile`

**Google user later creates password**  
`Google Sign-In` ➔ `Profile` ➔ `Create password` ➔ `Password linked` ➔ `Email/password login available`

**Existing password user**  
`Email/password sign in` ➔ `Profile` ➔ `Change password` ➔ `Current password` ➔ `New password` & `Confirm password`

## Current Status

Authentication and core profile functionality are implemented, including:
- [x] Email/password registration
- [x] Email/password login
- [x] Google Sign-In
- [x] Email verification
- [x] Forgot password
- [x] Password reset
- [x] Google account password creation
- [x] Password change
- [x] Profile display
- [x] Profile editing
- [x] Sign out
- [x] Account deletion
- [x] Firestore user profiles
- [x] Riverpod authentication state
- [x] Riverpod profile state
- [x] Firebase user change synchronization

## Future Improvements

Possible future additions include:
- Profile photo upload
- Username uniqueness
- Phone authentication
- Two-factor authentication
- Account linking UI
- More advanced profile fields
- Better error localization
- Automated tests
- Widget tests
- Integration tests
- Production Firestore security rules
- App-wide authentication guards
- Loading/error state improvements