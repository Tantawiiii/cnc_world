import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

final class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Future<String?> ensureSignedIn({String? customToken}) async {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser?.uid;
    }

    if (customToken != null && customToken.trim().isNotEmpty) {
      try {
        final credential = await _firebaseAuth.signInWithCustomToken(
          customToken.trim(),
        );
        return credential.user?.uid;
      } catch (e) {
        debugPrint('Firebase custom token sign-in failed: $e');
      }
    }

    try {
      final credential = await _firebaseAuth.signInAnonymously();
      return credential.user?.uid;
    } catch (e) {
      debugPrint('Firebase anonymous sign-in failed: $e');
      return null;
    }
  }
}
