import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Implements "One Student, One Device" binding using secure UUID tokens.
///
/// Flow:
///   1. First login → generate UUID → store locally + in Firestore
///   2. Subsequent logins → compare local token with Firestore token
///   3. Mismatch → redirect to face verification for device migration
class DeviceLockService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _tokenKey = 'attend_ease_device_token';
  static const int maxMigrationsPerSemester = 2;

  /// Generate a new device token and bind it to the user.
  Future<void> bindDevice(String uid) async {
    String? localToken = await _secureStorage.read(key: _tokenKey);

    if (localToken == null) {
      localToken = const Uuid().v4();
      await _secureStorage.write(key: _tokenKey, value: localToken);
    }

    await _firestore.collection('users').doc(uid).update({
      'bound_device_token': localToken,
    });
  }

  /// Verify if current device matches the bound device.
  /// Returns: true if device matches or first-time binding.
  Future<DeviceLockResult> verifyDevice(String uid) async {
    final localToken = await _secureStorage.read(key: _tokenKey);
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();

    if (data == null) return DeviceLockResult.userNotFound;

    final cloudToken = data['bound_device_token'] as String?;

    // First-time: no token stored yet → bind this device
    if (cloudToken == null) {
      await bindDevice(uid);
      return DeviceLockResult.bound;
    }

    // Local token is null (fresh install) or doesn't match
    if (localToken == null || localToken != cloudToken) {
      return DeviceLockResult.mismatch;
    }

    return DeviceLockResult.matched;
  }

  /// Migrate device lock to new phone (after face verification).
  /// Returns false if migration limit exceeded.
  Future<bool> migrateDevice(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return false;

    final migrationCount = (data['migration_count'] ?? 0) as int;

    if (migrationCount >= maxMigrationsPerSemester) {
      return false; // Limit reached
    }

    // Generate new token
    final newToken = const Uuid().v4();
    await _secureStorage.write(key: _tokenKey, value: newToken);

    await _firestore.collection('users').doc(uid).update({
      'bound_device_token': newToken,
      'migration_count': migrationCount + 1,
      'last_migration': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Get remaining migration attempts.
  Future<int> getRemainingMigrations(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final count = (doc.data()?['migration_count'] ?? 0) as int;
    return maxMigrationsPerSemester - count;
  }
}

enum DeviceLockResult {
  matched,     // ✅ Same device
  bound,       // ✅ First-time binding complete
  mismatch,    // ❌ Different device detected
  userNotFound, // ❌ User document missing
}
