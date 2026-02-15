import 'package:flutter/material.dart';
import '../services/ink_service.dart';

class InkCanvas extends StatefulWidget {
  final Function(String) onTextRecognized;

  const InkCanvas({super.key, required this.onTextRecognized});

  @override
  State<InkCanvas> createState() => InkCanvasState(); // Made public for GlobalKey access
}

class InkCanvasState extends State<InkCanvas> {
  final InkService _inkService = InkService();

  // Stores the points for the visual "Cyan" trail on the screen
  List<Offset?> _points = [];

  void _onPanStart(DragStartDetails details) {
    _inkService.startStroke();
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _inkService.addPoint(details.localPosition.dx, details.localPosition.dy);
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) async {
    setState(() {
      _points.add(null); // Separator between strokes for the painter
    });

    // Digital Ink Recognition: Turn the drawing into text
    String result = await _inkService.recognize();
    if (result.isNotEmpty) {
      widget.onTextRecognized(result);
    }
  }

  // Phase 2: The "Correction Loop" clear logic
  // Accessed via GlobalKey<InkCanvasState> from InputScreen
  void clear() {
    setState(() {
      _points = [];
      _inkService.clear();
    });
  }

  @override
  void dispose() {
    _inkService.dispose(); // Clean up ML Kit resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent, // Ensures the container catches gestures
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        // Low Latency Fix: RepaintBoundary isolates the drawing layer from the rest of the UI
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _InkPainter(points: _points),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _InkPainter extends CustomPainter {
  final List<Offset?> points;

  _InkPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors
          .cyanAccent // High-visibility "Neon" color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InkPainter oldDelegate) {
    // Optimization: Only repaint if the number of points has changed
    return oldDelegate.points.length != points.length;
  }
}
