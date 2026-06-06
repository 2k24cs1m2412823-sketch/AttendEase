import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Liveness detection using Google ML Kit face classification.
///
/// Challenges users with random actions (blink, smile) to prove
/// they are a real person and not a photo/video.
class LivenessService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  LivenessState _state = LivenessState.waiting;
  LivenessChallenge? _currentChallenge;
  DateTime? _challengeStartTime;

  static const Duration _challengeTimeout = Duration(seconds: 10);

  LivenessState get state => _state;
  LivenessChallenge? get currentChallenge => _currentChallenge;

  /// Start a new liveness challenge session.
  void startChallenge() {
    _currentChallenge = _getRandomChallenge();
    _state = LivenessState.challenging;
    _challengeStartTime = DateTime.now();
  }

  /// Process a camera frame for liveness detection.
  /// Returns true when the challenge is completed successfully.
  Future<LivenessResult> processFrame(InputImage image) async {
    if (_state != LivenessState.challenging) {
      return LivenessResult(passed: false, message: 'No active challenge.');
    }

    // Check timeout
    if (DateTime.now().difference(_challengeStartTime!) > _challengeTimeout) {
      _state = LivenessState.failed;
      return LivenessResult(passed: false, message: 'Challenge timed out.');
    }

    final faces = await _faceDetector.processImage(image);

    // Must detect exactly one face
    if (faces.isEmpty) {
      return LivenessResult(passed: false, message: 'No face detected.');
    }
    if (faces.length > 1) {
      return LivenessResult(
          passed: false, message: 'Multiple faces detected.');
    }

    final face = faces.first;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final smiling = face.smilingProbability ?? 0.0;

    bool challengePassed = false;

    switch (_currentChallenge!) {
      case LivenessChallenge.blink:
        // Eyes must be closed (both < 0.3)
        challengePassed = leftEyeOpen < 0.3 && rightEyeOpen < 0.3;
        break;
      case LivenessChallenge.smile:
        // Must smile (> 0.7 probability)
        challengePassed = smiling > 0.7;
        break;
      case LivenessChallenge.neutral:
        // Must have neutral expression (no smile, eyes open)
        challengePassed =
            smiling < 0.2 && leftEyeOpen > 0.7 && rightEyeOpen > 0.7;
        break;
    }

    if (challengePassed) {
      _state = LivenessState.passed;
      return LivenessResult(
        passed: true,
        message: 'Liveness verified!',
        face: face,
      );
    }

    return LivenessResult(
      passed: false,
      message: _getChallengePrompt(_currentChallenge!),
    );
  }

  LivenessChallenge _getRandomChallenge() {
    final challenges = LivenessChallenge.values;
    return challenges[DateTime.now().millisecondsSinceEpoch %
        challenges.length];
  }

  String _getChallengePrompt(LivenessChallenge challenge) {
    switch (challenge) {
      case LivenessChallenge.blink:
        return 'Please blink your eyes';
      case LivenessChallenge.smile:
        return 'Please smile';
      case LivenessChallenge.neutral:
        return 'Keep a neutral expression';
    }
  }

  /// Reset for a new challenge.
  void reset() {
    _state = LivenessState.waiting;
    _currentChallenge = null;
    _challengeStartTime = null;
  }

  void dispose() {
    _faceDetector.close();
  }
}

enum LivenessState { waiting, challenging, passed, failed }

enum LivenessChallenge { blink, smile, neutral }

class LivenessResult {
  final bool passed;
  final String message;
  final Face? face;

  LivenessResult({required this.passed, required this.message, this.face});
}
