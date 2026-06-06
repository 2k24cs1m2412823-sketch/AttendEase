import 'dart:convert';
import 'package:crypto/crypto.dart';

/// QR code validation service for seat scanning.
///
/// QR codes on desks contain a JSON payload with seat ID, room ID,
/// and an HMAC hash to prevent forgery.
///
/// Payload format:
/// {
///   "seat": "A1",
///   "room": "LAB_101",
///   "hash": "sha256(seat + room + secret)"
/// }
class QRService {
  // In production, load from environment/config
  static const String _secret = 'ATTEND_EASE_QR_SECRET_2024';

  /// Validate a scanned QR code against the expected room.
  QRValidationResult validateQR(String rawData, String expectedRoom) {
    try {
      final data = jsonDecode(rawData) as Map<String, dynamic>;

      final seat = data['seat'] as String?;
      final room = data['room'] as String?;
      final hash = data['hash'] as String?;

      if (seat == null || room == null || hash == null) {
        return QRValidationResult(
          valid: false,
          error: 'Invalid QR code format.',
        );
      }

      // 1. Verify room matches the active session
      if (room != expectedRoom) {
        return QRValidationResult(
          valid: false,
          seatId: seat,
          roomId: room,
          error: 'This QR code belongs to room "$room", '
              'but the active session is in "$expectedRoom".',
        );
      }

      // 2. Verify hash integrity (prevents forged QR codes)
      final expectedHash =
          sha256.convert(utf8.encode('$seat$room$_secret')).toString();

      if (hash != expectedHash) {
        return QRValidationResult(
          valid: false,
          error: 'QR code authentication failed. Possible forgery detected.',
        );
      }

      return QRValidationResult(
        valid: true,
        seatId: seat,
        roomId: room,
      );
    } on FormatException {
      return QRValidationResult(
        valid: false,
        error: 'Could not read QR code. Please try again.',
      );
    }
  }

  /// Generate QR code payload for a given seat and room.
  /// Used by admin tools to print QR codes for desks.
  static String generatePayload(String seat, String room) {
    final hash =
        sha256.convert(utf8.encode('$seat$room$_secret')).toString();
    return jsonEncode({'seat': seat, 'room': room, 'hash': hash});
  }
}

class QRValidationResult {
  final bool valid;
  final String? seatId;
  final String? roomId;
  final String? error;

  QRValidationResult({
    required this.valid,
    this.seatId,
    this.roomId,
    this.error,
  });
}
