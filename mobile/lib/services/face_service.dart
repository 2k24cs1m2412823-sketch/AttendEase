import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// On-device face recognition using MobileFaceNet (TFLite).
///
/// Input:  [1, 112, 112, 3] RGB image
/// Output: [1, 192] embedding vector
/// Match:  Euclidean distance < threshold (0.75)
class FaceService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Load the MobileFaceNet TFLite model from assets.
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('models/mobilefacenet.tflite');
      _isModelLoaded = true;
    } catch (e) {
      _isModelLoaded = false;
      rethrow;
    }
  }

  /// Convert a face image to a 192-dimensional embedding vector.
  List<double> getEmbedding(img.Image faceImage) {
    if (_interpreter == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    // 1. Resize to 112x112
    final resized = img.copyResize(faceImage, width: 112, height: 112);

    // 2. Normalize pixel values to [-1, 1]
    final input = Float32List(1 * 112 * 112 * 3);
    int idx = 0;
    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = resized.getPixel(x, y);
        input[idx++] = (pixel.r / 127.5) - 1.0;
        input[idx++] = (pixel.g / 127.5) - 1.0;
        input[idx++] = (pixel.b / 127.5) - 1.0;
      }
    }

    // 3. Run inference
    final inputTensor = input.reshape([1, 112, 112, 3]);
    final outputTensor = List.generate(1, (_) => Float32List(192));
    _interpreter!.run(inputTensor, outputTensor);

    return outputTensor[0].map((e) => e.toDouble()).toList();
  }

  /// Calculate Euclidean distance between two embedding vectors.
  double calculateDistance(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) {
      throw ArgumentError('Vectors must have the same length.');
    }
    double sum = 0.0;
    for (int i = 0; i < vec1.length; i++) {
      final diff = vec1[i] - vec2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  /// Verify if two face embeddings belong to the same person.
  bool verifyFace(
    List<double> liveEmbedding,
    List<double> storedEmbedding, {
    double threshold = 0.75,
  }) {
    final distance = calculateDistance(liveEmbedding, storedEmbedding);
    return distance < threshold;
  }

  /// Average multiple embeddings (for enrollment with 3 photos).
  List<double> averageEmbeddings(List<List<double>> embeddings) {
    if (embeddings.isEmpty) throw ArgumentError('No embeddings to average.');

    final length = embeddings.first.length;
    final averaged = List.filled(length, 0.0);

    for (final embedding in embeddings) {
      for (int i = 0; i < length; i++) {
        averaged[i] += embedding[i];
      }
    }

    for (int i = 0; i < length; i++) {
      averaged[i] /= embeddings.length;
    }

    return averaged;
  }

  void dispose() {
    _interpreter?.close();
  }
}
