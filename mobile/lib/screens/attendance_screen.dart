import 'package:flutter/material.dart';

/// Multi-step attendance screen:
///   Step 1: BLE Proximity Check
///   Step 2: QR Seat Scan
///   Step 3: Damage Declaration
///   Step 4: Liveness + Face Verification
///   Step 5: Result
class AttendanceScreen extends StatefulWidget {
  final String sessionId;
  const AttendanceScreen({super.key, required this.sessionId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _currentStep = 0;

  final List<String> _stepLabels = [
    'Bluetooth Check',
    'Scan Seat QR',
    'Damage Check',
    'Face Verification',
    'Done',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(_stepLabels.length, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                return Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isCompleted
                            ? theme.colorScheme.primary
                            : isActive
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepLabels[index],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const Divider(),

          // Step content
          Expanded(
            child: Center(
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    // TODO: Implement each step with actual service calls
    final theme = Theme.of(context);

    final stepIcons = [
      Icons.bluetooth_searching,
      Icons.qr_code_scanner,
      Icons.report_problem_outlined,
      Icons.face,
      Icons.check_circle_outline,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(stepIcons[_currentStep], size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          _stepLabels[_currentStep],
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${_currentStep + 1} of ${_stepLabels.length}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 32),
        if (_currentStep < _stepLabels.length - 1)
          FilledButton.icon(
            onPressed: () => setState(() => _currentStep++),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next Step'),
          ),
      ],
    );
  }
}
