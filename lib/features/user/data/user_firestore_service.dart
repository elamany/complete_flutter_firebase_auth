import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserFirestoreService {
  UserFirestoreService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  DocumentReference<Map<String, dynamic>>
      userDocument(String uid) {
    return _usersCollection.doc(uid);
  }

  Future<AppUser?> getUser(String uid) async {
    final document = await userDocument(uid).get();

    if (!document.exists) {
      return null;
    }

    return AppUser.fromDocument(document);
  }

  Stream<AppUser?> watchUser(String uid) {
    return userDocument(uid).snapshots().map(
      (document) {
        if (!document.exists) {
          return null;
        }

        return AppUser.fromDocument(document);
      },
    );
  }

  Future<void> createUserIfNotExists({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    await userDocument(uid).set(
      {
        'email': email,
        'displayName': displayName,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<void> updateProfile({
    required String uid,
    required String displayName,
  }) async {
    await userDocument(uid).update({
      'displayName': displayName,
      'profileCompleted': true,
    });
  }

  Future<void> deleteUser(String uid) async {
    await userDocument(uid).delete();
  }
}