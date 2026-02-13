import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class InkService {
  // Use 'en-US' as default language for Digital Ink Recognition
  final String _languageCode = 'en-US';

  // Late initialization to prevent main-thread blocking during object creation
  DigitalInkRecognizer? _recognizer;

  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();

  // The 'Ink' object holds all strokes and points
  final Ink _ink = Ink();

  // Custom Calibration: Minimum distance a finger must move to register a new point
  // This filters out the X657B's "touch jitter"
  final double _jitterFilterThreshold = 1.5;
  Offset? _lastPoint;

  /// Check if the model is already present on the device
  Future<bool> isModelDownloaded() async {
    return await _modelManager.isModelDownloaded(_languageCode);
  }

  /// Phase 2: Ensures the 'en-US' model exists on device
  /// This provides the logic required by InputScreen's initState
  Future<bool> checkAndDownloadModel() async {
    try {
      bool isDownloaded = await _modelManager.isModelDownloaded(_languageCode);

      if (!isDownloaded) {
        // Explicitly trigger download to bypass "Waiting for Wi-Fi" when possible
        // Note: If logs still show "connectivity requirement", connect to Wi-Fi briefly.
        await _modelManager.downloadModel(_languageCode);

        // Re-check immediately to update internal state
        isDownloaded = await _modelManager.isModelDownloaded(_languageCode);
      }

      // Initialize the recognizer only after we are sure the model is available
      if (isDownloaded) {
        _recognizer ??= DigitalInkRecognizer(languageCode: _languageCode);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Model Download Error: $e');
      return false;
    }
  }

  /// Adds a point to the current active stroke.
  /// Includes "Precision Calibration" to smooth out hardware noise.
  void addPoint(double x, double y) {
    if (_ink.strokes.isEmpty) {
      startStroke();
    }

    final currentPoint = Offset(x, y);

    // Calibration Logic: Only add the point if the movement is significant
    // This prevents the "jagged lines" caused by budget touch digitizers
    if (_lastPoint != null) {
      final double distance = (currentPoint - _lastPoint!).distance;
      if (distance < _jitterFilterThreshold) return;
    }

    _lastPoint = currentPoint;

    _ink.strokes.last.points.add(
      StrokePoint(x: x, y: y, t: DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Starts a new stroke (finger down on the canvas).
  void startStroke() {
    _lastPoint = null; // Reset calibration for new stroke
    _ink.strokes.add(Stroke());
  }

  /// Processes the captured 'Ink' and returns the recognized text.
  Future<String> recognize() async {
    try {
      if (_ink.strokes.isEmpty) return "";

      // Check if model is actually ready to avoid "Davey" main-thread hangs
      bool ready = await isModelDownloaded();
      if (!ready) {
        debugPrint('Recognition attempted but model is not yet downloaded.');
        return "Downloading model...";
      }

      // Ensure recognizer is ready before processing to avoid crashes
      if (_recognizer == null) {
        await checkAndDownloadModel();
      }

      final List<RecognitionCandidate> candidates = await _recognizer!
          .recognize(_ink);

      return candidates.isNotEmpty ? candidates.first.text : "";
    } catch (e) {
      debugPrint('Recognition Error: $e');
      return "";
    }
  }

  /// Clears the digital ink data for a fresh handwriting session.
  void clear() {
    _ink.strokes.clear();
    _lastPoint = null;
  }

  /// Essential for Phase 2: Frees up system resources when input stage is closed.
  void dispose() {
    _recognizer?.close();
  }
}
