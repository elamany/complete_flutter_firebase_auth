import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/user_firestore_service.dart';
import '../models/app_user.dart';


final userFirestoreServiceProvider =
    Provider<UserFirestoreService>((ref) {
  return UserFirestoreService();
});

final appUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(currentUserProvider);

  if (firebaseUser == null) {
    return Stream.value(null);
  }

  final userService = ref.watch(
    userFirestoreServiceProvider,
  );

  return userService.watchUser(firebaseUser.uid);
});