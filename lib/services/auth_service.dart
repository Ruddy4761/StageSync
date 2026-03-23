import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get userId => _auth.currentUser?.uid ?? '';

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email & password
  Future<({bool success, String? error})> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return (success: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return (success: false, error: 'An unexpected error occurred');
    }
  }

  // Sign in with email & password
  Future<({bool success, String? error})> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (success: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return (success: false, error: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<({bool success, String? error})> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return (success: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return (success: false, error: 'An unexpected error occurred');
    }
  }

  // Get display name
  String get displayName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? 'User';

  // Get user email
  String get email => _auth.currentUser?.email ?? '';

  // Human-readable auth error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
