import 'package:flutter/services.dart';

class HapticService {
  /// Provides a light vibration when the finger slides over a new word
  /// in the Quick-Action bubble grid[cite: 11, 51].
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Provides a medium vibration when the user confirms an action,
  /// such as tapping the checkmark to "Go Live".
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Provides a heavy vibration to indicate an error or a
  /// significant event, like clearing the canvas (X).
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// A specific pulse for the "Correction Loop" verification[cite: 13, 51].
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
