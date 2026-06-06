import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles roll-number-based authentication using Firebase Auth.
///
/// Roll numbers are converted to synthetic emails:
///   CS-2024-001 → cs-2024-001@attendease.app
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Convert institutional ID to a synthetic Firebase email.
  String _toSyntheticEmail(String rollNo) =>
      '${rollNo.toLowerCase().replaceAll(' ', '')}@attendease.app';

  /// Sign in with roll number + password.
  Future<UserCredential> login(String rollNo, String password) async {
    final email = _toSyntheticEmail(rollNo);
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register a new user with roll number, password, and profile data.
  Future<UserCredential> register(
    String rollNo,
    String password, {
    required String recoveryEmail,
    required String role, // 'student' | 'teacher'
    required String fullName,
  }) async {
    final email = _toSyntheticEmail(rollNo);
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create Firestore user profile
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'institutional_id': rollNo.toUpperCase(),
      'full_name': fullName,
      'role': role,
      'recovery_email': recoveryEmail,
      'bound_device_token': null,
      'face_embedding': <double>[],
      'migration_count': 0,
      'created_at': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  /// Get the current user's Firestore profile.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Get user role ('student' | 'teacher').
  Future<String?> getUserRole() async {
    final profile = await getUserProfile();
    return profile?['role'] as String?;
  }

  /// Send password reset to the user's recovery email.
  Future<void> resetPassword(String rollNo) async {
    // Look up recovery email from Firestore
    final query = await _firestore
        .collection('users')
        .where('institutional_id', isEqualTo: rollNo.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Roll number not found.');
    }

    final recoveryEmail = query.docs.first.data()['recovery_email'] as String;
    // Note: In production, use Cloud Functions to send a custom reset email
    // to the recovery address. Firebase Auth reset goes to the synthetic email.
    await _auth.sendPasswordResetEmail(email: recoveryEmail);
  }

  /// Sign out.
  Future<void> logout() => _auth.signOut();
}
