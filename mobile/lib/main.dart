import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/auth_service.dart';
import 'services/device_lock_service.dart';
import 'services/face_service.dart';
import 'services/bluetooth_service.dart';
import 'services/qr_service.dart';
import 'services/offline_queue_service.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox('pending_attendance');
  await Hive.openBox('app_state');

  // Pre-load TFLite model
  final faceService = FaceService();
  await faceService.loadModel();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DeviceLockService>(create: (_) => DeviceLockService()),
        Provider<FaceService>(create: (_) => faceService),
        Provider<BluetoothService>(create: (_) => BluetoothService()),
        Provider<QRService>(create: (_) => QRService()),
        Provider<OfflineQueueService>(create: (_) => OfflineQueueService()),
      ],
      child: const AttendEaseApp(),
    ),
  );
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AttendEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Outfit',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Outfit',
      ),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
