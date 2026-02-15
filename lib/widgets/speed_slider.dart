import 'package:flutter/material.dart';

class SpeedSlider extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedSlider({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: const Border(left: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.speed, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          const Text(
            "SPEED",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3, // Rotates the horizontal slider to be vertical
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  activeTrackColor: Colors.cyanAccent,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: Colors.cyanAccent,
                ),
                child: Slider(
                  value: currentSpeed,
                  min: 0,
                  max: 10,
                  divisions: 10, // Creates discrete steps from 0-10
                  label: currentSpeed.round().toString(),
                  onChanged: onSpeedChanged,
                ),
              ),
            ),
          ),
          // Visual indicator for 0 (Static)
          Text(
            currentSpeed == 0 ? "STATIC" : "SCROLL",
            style: TextStyle(
              color: currentSpeed == 0 ? Colors.redAccent : Colors.greenAccent,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
