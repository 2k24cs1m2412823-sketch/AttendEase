import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Orchestrates the full attendance marking flow:
///   1. BLE proximity check
///   2. QR seat scan
///   3. Damage declaration
///   4. Liveness detection
///   5. Face verification
///   6. Record to Firestore (or offline queue)
///
/// Each step must pass before proceeding to the next.
class AttendanceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new active session (Teacher side).
  Future<String> startSession({
    required String teacherId,
    required String roomId,
    required String subject,
    required String beaconUUID,
    required List<String> validSeats,
  }) async {
    final sessionDoc = await _firestore.collection('active_sessions').add({
      'teacher_id': teacherId,
      'room_id': roomId,
      'subject': subject,
      'beacon_uuid': beaconUUID,
      'is_active': true,
      'valid_seats': validSeats,
      'seat_map': <String, String>{},
      'started_at': FieldValue.serverTimestamp(),
    });
    return sessionDoc.id;
  }

  /// End an active session (Teacher side).
  Future<void> endSession(String sessionId) async {
    await _firestore.collection('active_sessions').doc(sessionId).update({
      'is_active': false,
      'ended_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get active session details.
  Future<Map<String, dynamic>?> getActiveSession(String sessionId) async {
    final doc =
        await _firestore.collection('active_sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  /// Get all currently active sessions (for student home screen).
  Stream<QuerySnapshot> getActiveSessions() {
    return _firestore
        .collection('active_sessions')
        .where('is_active', isEqualTo: true)
        .snapshots();
  }

  /// Check if a seat is already occupied in the session.
  Future<bool> isSeatOccupied(String sessionId, String seatId) async {
    final doc =
        await _firestore.collection('active_sessions').doc(sessionId).get();
    final seatMap =
        Map<String, dynamic>.from(doc.data()?['seat_map'] ?? {});
    return seatMap.containsKey(seatId);
  }

  /// Record attendance to Firestore.
  Future<void> recordAttendance({
    required String sessionId,
    required String studentId,
    required String seatId,
    required double verificationScore,
    int? bleRssi,
  }) async {
    // Save attendance log
    await _firestore.collection('attendance_logs').add({
      'session_id': sessionId,
      'student_id': studentId,
      'seat_id': seatId,
      'timestamp': FieldValue.serverTimestamp(),
      'verification_score': verificationScore,
      'ble_rssi': bleRssi,
    });

    // Update session seat map
    await _firestore
        .collection('active_sessions')
        .doc(sessionId)
        .update({'seat_map.$seatId': studentId});
  }

  /// Upload a damage report.
  Future<void> reportDamage({
    required String seatId,
    required String sessionId,
    required String reportedBy,
    required String imageUrl,
  }) async {
    await _firestore.collection('damage_reports').add({
      'seat_id': seatId,
      'session_id': sessionId,
      'reported_by': reportedBy,
      'image_url': imageUrl,
      'flag': 'GREEN', // Pre-existing damage
      'suspect_uid': null,
      'reported_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get attendance logs for a session.
  Stream<QuerySnapshot> getSessionAttendance(String sessionId) {
    return _firestore
        .collection('attendance_logs')
        .where('session_id', isEqualTo: sessionId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get a student's attendance history.
  Stream<QuerySnapshot> getStudentHistory(String studentId) {
    return _firestore
        .collection('attendance_logs')
        .where('student_id', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
