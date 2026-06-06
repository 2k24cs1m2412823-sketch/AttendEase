import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/face_enroll_screen.dart';
import 'screens/face_verify_screen.dart';
import 'screens/damage_report_screen.dart';
import 'screens/session_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/attendance/:sessionId',
      builder: (context, state) => AttendanceScreen(
        sessionId: state.pathParameters['sessionId']!,
      ),
    ),
    GoRoute(
      path: '/enroll-face',
      builder: (context, state) => const FaceEnrollScreen(),
    ),
    GoRoute(
      path: '/verify-face',
      builder: (context, state) => const FaceVerifyScreen(),
    ),
    GoRoute(
      path: '/damage-report',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        return DamageReportScreen(
          seatId: extra['seatId']!,
          sessionId: extra['sessionId']!,
        );
      },
    ),
    // Teacher routes
    GoRoute(
      path: '/session/start',
      builder: (context, state) => const SessionScreen(),
    ),
  ],
);
