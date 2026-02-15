import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Required for Strobe Timer
import 'package:marquee/marquee.dart';
import 'package:screen_brightness/screen_brightness.dart'; // Ensure this is in pubspec.yaml

class DisplayScreen extends StatefulWidget {
  final String text;
  final double scrollSpeed;
  final double textSize; // Added for text size control
  final Color textColor;
  final Color backgroundColor;
  final bool strobeEnabled; // Added for manual strobe control
  final String fontStyle; // Receives "Normal", "Italic", "Cursive", etc.

  const DisplayScreen({
    super.key,
    required this.text,
    required this.scrollSpeed,
    required this.textSize, // Required in constructor
    required this.textColor,
    required this.backgroundColor,
    this.strobeEnabled = false,
    this.fontStyle = "Normal",
  });

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  double _originalBrightness = 0.5;
  bool _isFlashOn = false;
  bool _isPaused = false; // Track if movement is currently stopped
  Timer? _strobeTimer;

  // Track which words are specifically "highlighted/paused" in the static view
  final Set<int> _pausedWordIndices = {};

  @override
  void initState() {
    super.initState();
    _initDisplaySettings();
    _startStrobeEffect();
  }

  Future<void> _initDisplaySettings() async {
    // Phase 3: Hide the status bar (Time, Battery, Signal)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Phase 3: Force Landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Zoomer Special: Save current brightness and set to MAX
    try {
      _originalBrightness = await ScreenBrightness.instance.application;
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (e) {
      debugPrint("Brightness error: $e");
    }
  }

  void _startStrobeEffect() {
    // Logic: Strobe if manually enabled OR if speed is high (> 7)
    if (widget.strobeEnabled || widget.scrollSpeed > 7.0) {
      _strobeTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (mounted && !_isPaused) {
          setState(() {
            _isFlashOn = !_isFlashOn;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _strobeTimer?.cancel(); // Essential: Clean up timer
    _restoreDisplaySettings();
    super.dispose();
  }

  Future<void> _restoreDisplaySettings() async {
    // Restore orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Restore original brightness
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(
        _originalBrightness,
      );
    } catch (e) {
      debugPrint("Brightness restore error: $e");
    }
  }

  void _handleExit() {
    // Return UI to normal and pop
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pop(context);
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _isFlashOn = false; // Turn off glow when paused
      } else {
        _pausedWordIndices
            .clear(); // Clear individual word highlights when resuming
      }
    });
    HapticFeedback.mediumImpact(); // Feedback for the tap
  }

  // Senior Dev Tip: Centralize style logic so it matches the InputScreen exactly
  TextStyle _getAppliedTextStyle(double fontSize, List<Shadow> shadows) {
    switch (widget.fontStyle) {
      case "Italic":
        return TextStyle(
          color: widget.textColor,
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          shadows: shadows,
        );
      case "Bold":
        return TextStyle(
          color: widget.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: shadows,
        );
      case "Cursive":
        return TextStyle(
          color: widget.textColor,
          fontSize: fontSize,
          fontFamily: 'DancingScript',
          fontStyle: FontStyle.italic,
          letterSpacing: 2,
          shadows: shadows,
        );
      case "Monospace":
        return TextStyle(
          color: widget.textColor,
          fontSize: fontSize,
          fontFamily: 'monospace',
          shadows: shadows,
        );
      default:
        return TextStyle(
          color: widget.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold, // Default Zoomer style is usually bold
          shadows: shadows,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool useMarquee = widget.scrollSpeed > 0;
    List<String> words = widget.text.split(' ');
    final screenHeight = MediaQuery.of(context).size.height;

    // Optimization: Define a glow effect instead of a background flash
    final List<Shadow> textShadows = (_isFlashOn && !_isPaused)
        ? [
            Shadow(
              blurRadius: 30.0,
              color: widget.textColor.withValues(alpha: 0.8),
              offset: const Offset(0, 0),
            ),
          ]
        : [];

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          // Main Interaction Layer - Behavior set to Opaque to catch all taps
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: _handleExit,
            onTap: _togglePause,
            child: Center(
              child: RepaintBoundary(
                child: (useMarquee && !_isPaused)
                    ? IgnorePointer(
                        // Marquee widget sometimes intercepts taps; IgnorePointer lets it pass to the main detector
                        child: SizedBox(
                          height: screenHeight,
                          child: Marquee(
                            text: widget.text,
                            style: _getAppliedTextStyle(
                              widget.textSize, // Applied dynamic text size
                              textShadows,
                            ),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            blankSpace: 300.0,
                            velocity: widget.scrollSpeed * 25,
                            pauseAfterRound: const Duration(seconds: 1),
                          ),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: words.asMap().entries.map((entry) {
                              int idx = entry.key;
                              String word = entry.value;
                              bool isWordPaused = _pausedWordIndices.contains(
                                idx,
                              );

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isWordPaused) {
                                      _pausedWordIndices.remove(idx);
                                    } else {
                                      _pausedWordIndices.add(idx);
                                    }
                                  });
                                  HapticFeedback.selectionClick();
                                },
                                child: Text(
                                  '$word ',
                                  style:
                                      _getAppliedTextStyle(
                                            widget.textSize,
                                            textShadows,
                                          ) // Applied dynamic text size
                                          .copyWith(
                                            color: isWordPaused
                                                ? Colors.redAccent
                                                : widget.textColor,
                                            backgroundColor: isWordPaused
                                                ? widget.textColor.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.transparent,
                                          ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Side Hover Exit Feature
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 50,
            child: MouseRegion(
              onEnter: (_) => _handleExit(),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Visual Status Indicator
          if (_isPaused)
            Positioned(
              top: 20,
              right: 20,
              child: Icon(
                Icons.pause_circle_outline,
                color: widget.textColor.withValues(alpha: 0.3),
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}
