import 'package:flutter/material.dart';

/// Teacher session management screen — start/stop attendance sessions,
/// configure BLE beacon, and view real-time seat map.
class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cast_for_education,
                size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Start a Session',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a new attendance session. Your phone will '
              'broadcast a BLE beacon for student proximity checks.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // TODO: Room selector, subject input, seat count
            FilledButton.icon(
              onPressed: () {
                // TODO: Start BLE advertising + create Firestore session
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session'),
            ),
          ],
        ),
      ),
    );
  }
}
