import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.profileCompleted,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final bool profileCompleted;
  final DateTime? createdAt;

  factory AppUser.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'User document does not contain data.',
      );
    }

    final createdAt = data['createdAt'];

    return AppUser(
      uid: document.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      profileCompleted:
          data['profileCompleted'] as bool? ?? false,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}