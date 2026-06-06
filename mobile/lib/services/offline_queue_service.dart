import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Offline queue service for attendance records.
///
/// When the device is offline, attendance records are saved locally
/// in Hive and synced to Firestore when connectivity is restored.
class OfflineQueueService {
  static const String _boxName = 'pending_attendance';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Box get _box => Hive.box(_boxName);

  /// Check if device is currently online.
  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Enqueue an attendance record for later sync.
  Future<void> enqueue(Map<String, dynamic> record) async {
    await _box.add({
      ...record,
      'synced': false,
      'queued_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get count of pending (unsynced) records.
  int get pendingCount {
    int count = 0;
    for (int i = 0; i < _box.length; i++) {
      final record = _box.getAt(i) as Map?;
      if (record != null && record['synced'] == false) {
        count++;
      }
    }
    return count;
  }

  /// Sync all pending records to Firestore.
  /// Returns the number of successfully synced records.
  Future<int> syncAll() async {
    if (!await isOnline()) return 0;

    int synced = 0;
    for (int i = 0; i < _box.length; i++) {
      final record = Map<String, dynamic>.from(_box.getAt(i) as Map);
      if (record['synced'] == false) {
        try {
          // Remove local-only fields before uploading
          final uploadData = Map<String, dynamic>.from(record)
            ..remove('synced')
            ..remove('queued_at');

          // Add server timestamp
          uploadData['timestamp'] = FieldValue.serverTimestamp();
          uploadData['synced_from_offline'] = true;

          await _firestore.collection('attendance_logs').add(uploadData);

          // Mark as synced
          record['synced'] = true;
          await _box.putAt(i, record);
          synced++;
        } catch (e) {
          // Skip failed records, will retry next sync
          continue;
        }
      }
    }

    return synced;
  }

  /// Clear all synced records to free storage.
  Future<void> clearSynced() async {
    final keysToDelete = <dynamic>[];
    for (int i = 0; i < _box.length; i++) {
      final record = _box.getAt(i) as Map?;
      if (record != null && record['synced'] == true) {
        keysToDelete.add(_box.keyAt(i));
      }
    }
    await _box.deleteAll(keysToDelete);
  }

  /// Start listening for connectivity changes and auto-sync.
  void startAutoSync() {
    Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncAll(); // Auto-sync when connection is restored
      }
    });
  }
}
