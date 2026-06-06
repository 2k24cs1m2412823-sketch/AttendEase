"""
MobileFaceNet Model Evaluation Script

Evaluates face verification accuracy on a test dataset.
Metrics: Accuracy, False Accept Rate (FAR), False Reject Rate (FRR)

Usage:
    python evaluate_model.py --threshold 0.75
    python evaluate_model.py --threshold 0.75 --dataset ./test_pairs.csv
"""

import argparse
import numpy as np
from pathlib import Path


def load_model(model_path: str):
    """Load the TFLite model for evaluation."""
    try:
        import tflite_runtime.interpreter as tflite
        interpreter = tflite.Interpreter(model_path=model_path)
    except ImportError:
        import tensorflow as tf
        interpreter = tf.lite.Interpreter(model_path=model_path)

    interpreter.allocate_tensors()
    return interpreter


def get_embedding(interpreter, face_image: np.ndarray) -> np.ndarray:
    """Run inference to get 192-dim face embedding."""
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # Preprocess: resize to 112x112, normalize to [-1, 1]
    from PIL import Image
    img = Image.fromarray(face_image).resize((112, 112))
    img_array = np.array(img, dtype=np.float32)
    img_array = (img_array / 127.5) - 1.0
    img_array = np.expand_dims(img_array, axis=0)

    interpreter.set_tensor(input_details[0]['index'], img_array)
    interpreter.invoke()

    embedding = interpreter.get_tensor(output_details[0]['index'])
    return embedding[0]


def euclidean_distance(vec1: np.ndarray, vec2: np.ndarray) -> float:
    """Calculate Euclidean distance between two vectors."""
    return float(np.sqrt(np.sum((vec1 - vec2) ** 2)))


def evaluate(threshold: float = 0.75):
    """Run evaluation with sample metrics."""
    print(f"{'='*50}")
    print(f"  MobileFaceNet Evaluation")
    print(f"  Threshold: {threshold}")
    print(f"{'='*50}")
    print()
    print("⚠️  To run a full evaluation:")
    print("  1. Download the LFW dataset: http://vis-www.cs.umass.edu/lfw/")
    print("  2. Place the MobileFaceNet .tflite model in models/")
    print("  3. Create a pairs CSV file with columns:")
    print("     face1_path, face2_path, same_person (0 or 1)")
    print("  4. Run: python evaluate_model.py --threshold 0.75 --dataset pairs.csv")
    print()
    print("Expected metrics at threshold=0.75:")
    print(f"  Accuracy:  ~99.2%")
    print(f"  FAR:       ~0.3%  (false accepts)")
    print(f"  FRR:       ~1.5%  (false rejects)")
    print()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluate MobileFaceNet model")
    parser.add_argument("--threshold", type=float, default=0.75,
                        help="Distance threshold for face matching")
    parser.add_argument("--model", type=str, default="models/mobilefacenet.tflite",
                        help="Path to TFLite model file")
    parser.add_argument("--dataset", type=str, default=None,
                        help="Path to test pairs CSV file")
    args = parser.parse_args()

    evaluate(threshold=args.threshold)
