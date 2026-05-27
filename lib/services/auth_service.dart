import 'package:firebase_auth/firebase_auth.dart';
import 'package:shining/models/user_model.dart';
import 'package:shining/services/firestore_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Returns null on success, error message on failure.
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed. Please try again.';
    }
  }

  /// Creates account, saves profile to Firestore. Returns null on success.
  Future<String?> signUpWithEmail(
      String email, String password, String fullName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final user = UserModel(
        id: cred.user!.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: '',
        avatarUrl: '',
      );
      await FirestoreService().saveUserProfile(cred.user!.uid, user);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
