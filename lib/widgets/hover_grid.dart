import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoverGrid extends StatefulWidget {
  final Function(String) onHover;
  final Function(String) onTap; // Added onTap parameter
  final Function(int, String) onLongPress;
  final Function(int) onDelete;
  final VoidCallback onAdd; // Phase 5: Add word callback
  final List<String> words;

  const HoverGrid({
    super.key,
    required this.onHover,
    required this.onTap, // Required in constructor
    required this.words,
    required this.onLongPress,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<HoverGrid> createState() => _HoverGridState();
}

class _HoverGridState extends State<HoverGrid> {
  int? _hoveredIndex;

  void _checkHover(Offset localPosition, BoxConstraints constraints) {
    // Total items = words + the "Add" button
    int totalCount = widget.words.length + 1;
    double sectorWidth = constraints.maxWidth / totalCount;

    int index = (localPosition.dx / sectorWidth).floor().clamp(
      0,
      totalCount - 1,
    );

    if (_hoveredIndex != index) {
      setState(() => _hoveredIndex = index);
      HapticFeedback.lightImpact();

      // If hovering over a word (not the add button), update preview
      if (index < widget.words.length) {
        widget.onHover(widget.words[index]);
      }
    }
  }

  void _showActionMenu(BuildContext context, int index, String word) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.cyanAccent),
              title: Text(
                'Edit "$word"',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onLongPress(index, word);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Delete Word',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) =>
              _checkHover(details.localPosition, constraints),
          onPanEnd: (_) => setState(() => _hoveredIndex = null),
          child: Row(
            children: [
              // Word Bubbles
              ...List.generate(widget.words.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTap(
                      widget.words[index],
                    ), // Trigger onTap on touch
                    onLongPress: () =>
                        _showActionMenu(context, index, widget.words[index]),
                    child: _buildBubble(
                      label: widget.words[index],
                      isHovered: _hoveredIndex == index,
                      color: _hoveredIndex == index
                          ? Colors.cyan
                          : Colors.grey[800] ?? Colors.grey,
                    ),
                  ),
                );
              }),
              // Add Button Bubble
              Expanded(
                child: GestureDetector(
                  onTap: widget.onAdd,
                  child: _buildBubble(
                    label: "+",
                    isHovered: _hoveredIndex == widget.words.length,
                    color: _hoveredIndex == widget.words.length
                        ? Colors.greenAccent
                        : Colors.grey[900]!,
                    isAction: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBubble({
    required String label,
    required bool isHovered,
    required Color color,
    bool isAction = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: isAction ? Border.all(color: Colors.white10) : null,
        boxShadow: isHovered
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isAction && isHovered ? Colors.black : Colors.white,
          fontSize: isAction ? 20 : 12,
        ),
      ),
    );
  }
}
