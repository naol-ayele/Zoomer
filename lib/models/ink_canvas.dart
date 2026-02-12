import 'package:flutter/foundation.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class InkService {
  // Use 'en-US' as default language for Digital Ink Recognition
  final String _languageCode = 'en-US';
  late final DigitalInkRecognizer _recognizer;
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();

  // The 'Ink' object holds all strokes and points
  final Ink _ink = Ink();
  bool isReady = false;

  InkService() {
    _recognizer = DigitalInkRecognizer(languageCode: _languageCode);
  }

  /// Phase 2: Ensures the 'en-US' model exists on device
  /// This must be called during app initialization
  Future<bool> checkAndDownloadModel() async {
    try {
      final bool isDownloaded = await _modelManager.isModelDownloaded(
        _languageCode,
      );
      if (!isDownloaded) {
        // Triggers the background download from Google's servers
        await _modelManager.downloadModel(_languageCode);
      }
      isReady = true;
      return true;
    } catch (e) {
      debugPrint('Model Download Error: $e');
      return false;
    }
  }

  /// Adds a point to the current active stroke.
  /// Updated to use StrokePoint as per official documentation.
  void addPoint(double x, double y) {
    if (_ink.strokes.isEmpty) {
      startStroke();
    }
    _ink.strokes.last.points.add(
      StrokePoint(x: x, y: y, t: DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Starts a new stroke (finger down on the canvas).
  /// Updated to use Stroke as per official documentation.
  void startStroke() {
    _ink.strokes.add(Stroke());
  }

  /// Processes the captured 'Ink' and returns the recognized text.
  Future<String> recognize() async {
    try {
      if (!isReady || _ink.strokes.isEmpty) return "";

      final List<RecognitionCandidate> candidates = await _recognizer.recognize(
        _ink,
      );

      return candidates.isNotEmpty ? candidates.first.text : "";
    } catch (e) {
      debugPrint('Recognition Error: $e');
      return "";
    }
  }

  /// Clears the digital ink data for a fresh handwriting session.
  void clear() {
    _ink.strokes.clear();
  }

  /// Essential for Phase 2: Frees up system resources when input stage is closed.
  void dispose() {
    _recognizer.close();
  }
}
