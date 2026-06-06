import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Bluetooth Low Energy (BLE) proximity service.
///
/// Scans for the teacher's BLE beacon and validates RSSI signal
/// strength to ensure the student is physically inside the classroom.
class BluetoothService {
  /// RSSI thresholds:
  ///   -50 dBm = very close (~1m)
  ///   -70 dBm = room range (~5m)
  ///   -90 dBm = far/hallway
  static const int rssiThreshold = -70;

  int? lastRssi;

  /// Check if Bluetooth is available and turned on.
  Future<bool> isBluetoothAvailable() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    return adapterState == BluetoothAdapterState.on;
  }

  /// Scan for the teacher's beacon and validate proximity.
  /// Returns true if the beacon is found within acceptable range.
  Future<ProximityResult> validateProximity(String expectedBeaconUUID) async {
    if (!await isBluetoothAvailable()) {
      return ProximityResult(
        inRange: false,
        rssi: null,
        error: 'Bluetooth is not enabled. Please turn on Bluetooth.',
      );
    }

    bool found = false;
    int? detectedRssi;

    try {
      // Listen for scan results
      final subscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          final uuids = r.advertisementData.serviceUuids;
          if (uuids.any((guid) =>
              guid.toString().toLowerCase() ==
              expectedBeaconUUID.toLowerCase())) {
            detectedRssi = r.rssi;
            if (r.rssi > rssiThreshold) {
              found = true;
            }
          }
        }
      });

      // Scan for 10 seconds
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete
      await FlutterBluePlus.isScanning.where((s) => s == false).first;
      await subscription.cancel();
    } catch (e) {
      return ProximityResult(
        inRange: false,
        rssi: null,
        error: 'Bluetooth scan failed: ${e.toString()}',
      );
    }

    lastRssi = detectedRssi;

    if (!found && detectedRssi != null) {
      return ProximityResult(
        inRange: false,
        rssi: detectedRssi,
        error: 'You appear to be outside the classroom. '
            'Please move closer (signal: ${detectedRssi}dBm).',
      );
    }

    if (!found) {
      return ProximityResult(
        inRange: false,
        rssi: null,
        error: 'Classroom beacon not found. '
            'Make sure you are in the correct room.',
      );
    }

    return ProximityResult(inRange: true, rssi: detectedRssi);
  }
}

class ProximityResult {
  final bool inRange;
  final int? rssi;
  final String? error;

  ProximityResult({required this.inRange, this.rssi, this.error});
}
