import 'package:flutter/material.dart';

class ColorEngine extends StatelessWidget {
  final Color selectedTextColor;
  final Color selectedBgColor;
  final Function(Color) onTextColorChanged;
  final Function(Color) onBgColorChanged;

  // High-contrast colors defined in the MVP spec
  final List<Color> textColors = [
    const Color(0xFFFFFF00), // Neon Yellow
    Colors.white,
    Colors.cyan,
  ];

  final List<Color> bgColors = [
    Colors.black, // Pure Black for OLED [cite: 50]
    const Color(0xFF000033), // Dark Blue
    const Color(0xFF330000), // Dark Red
  ];

  ColorEngine({
    super.key,
    required this.selectedTextColor,
    required this.selectedBgColor,
    required this.onTextColorChanged,
    required this.onBgColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TEXT COLOR",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: textColors
              .map((color) => _colorPicker(color, true))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          "BG COLOR",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: bgColors
              .map((color) => _colorPicker(color, false))
              .toList(),
        ),
      ],
    );
  }

  Widget _colorPicker(Color color, bool isText) {
    bool isSelected = isText
        ? selectedTextColor == color
        : selectedBgColor == color;

    return GestureDetector(
      onTap: () => isText ? onTextColorChanged(color) : onBgColorChanged(color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
              : [],
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 20, color: Colors.grey)
            : null,
      ),
    );
  }
}
