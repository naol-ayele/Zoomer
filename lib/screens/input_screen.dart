import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoomer/widgets/color_engine.dart';
import 'display_screen.dart';
import '../widgets/ink_canvas.dart';
import '../widgets/hover_grid.dart';
import '../services/storage_service.dart';
import '../services/ink_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  final StorageService _storage = StorageService();
  final InkService _inkService = InkService();
  final GlobalKey<InkCanvasState> _canvasKey = GlobalKey();

  double _scrollSpeed = 5.0;
  double _textSize = 150.0; // Zoomer: Default display text size
  Color _selectedTextColor = Colors.yellow;
  Color _selectedBgColor = Colors.black;
  bool _isEngineReady = false; // Track engine status
  bool _strobeEnabled = false; // Zoomer Toggle: Manual Strobe Control
  bool _showSidePanel = false; // Toggle for maximizing drawing space
  bool _showColorPicker = false; // Toggle for color engine visibility
  bool _showFontPicker = false; // Toggle for font style visibility

  // Font style selection
  String _selectedFontStyle = "Normal";
  final List<String> _fontStyles = [
    "Normal",
    "Italic",
    "Cursive",
    "Bold",
    "Monospace",
  ];

  List<String> _quickWords = ["YES", "NO", "WAIT", "STOP"];

  @override
  void initState() {
    super.initState();
    // Force Landscape Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _loadSavedWords();
    _initEngine();
  }

  Future<void> _initEngine() async {
    // Check if the handwriting model is already on the device
    bool isDownloaded = await _inkService.isModelDownloaded();

    if (!isDownloaded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Downloading handwriting engine (approx 20MB)..."),
          backgroundColor: Colors.blueGrey,
          duration: Duration(seconds: 4),
        ),
      );
    }

    // Phase 2: Initialize the ML Model with Status Feedback
    final success = await _inkService.checkAndDownloadModel();
    if (success && mounted) {
      setState(() => _isEngineReady = true);
      debugPrint("Handwriting engine ready!");
    }
  }

  @override
  void dispose() {
    // Reset orientation to system default when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _inkService.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedWords() async {
    final savedWords = await _storage.loadWords();
    if (mounted) {
      setState(() {
        _quickWords = savedWords;
      });
    }
  }

  // Helper to get the correct TextStyle based on selection
  TextStyle _getAppliedTextStyle(double fontSize) {
    switch (_selectedFontStyle) {
      case "Italic":
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
        );
      case "Bold":
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        );
      case "Cursive":
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontFamily:
              'DancingScript', // Requires adding font to pubspec, or falls back to stylized serif
          fontStyle: FontStyle.italic,
          letterSpacing: 2,
        );
      case "Monospace":
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontFamily: 'monospace',
        );
      default:
        return TextStyle(color: Colors.white, fontSize: fontSize);
    }
  }

  void _goLive({String? overrideText}) {
    final textToSend = overrideText ?? _textController.text;
    if (textToSend.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayScreen(
            text: textToSend,
            scrollSpeed: _scrollSpeed,
            textSize: _textSize, // Passing the new controlled text size
            textColor: _selectedTextColor,
            backgroundColor: _selectedBgColor,
            strobeEnabled: _strobeEnabled,
            fontStyle: _selectedFontStyle,
          ),
        ),
      );
    }
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _canvasKey.currentState?.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void _clearOnlyCanvas() {
    _canvasKey.currentState?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Wrap title in Flexible to prevent overflow by allowing it to shrink
        title: Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // INTEGRATED LOGO HERE
              Image.asset(
                'assets/images/logo.jpg', // Ensure this path matches your pubspec.yaml
                height: 24, // Reduced height to fit tight landscape appbars
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "Z", // Shortened fallback text to save horizontal pixels
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 6), // Reduced width to save pixels
              // Status Indicator Light
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isEngineReady
                      ? Colors.cyanAccent
                      : Colors.orangeAccent,
                  boxShadow: [
                    if (_isEngineReady)
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(
              Icons.font_download,
              color: _showFontPicker ? Colors.cyanAccent : Colors.white70,
            ),
            onPressed: () => setState(() {
              _showFontPicker = !_showFontPicker;
              if (_showFontPicker) _showColorPicker = false;
            }),
            tooltip: "Choose Font Style",
          ),
          IconButton(
            icon: Icon(
              Icons.palette,
              color: _showColorPicker ? Colors.cyanAccent : Colors.white70,
            ),
            onPressed: () => setState(() {
              _showColorPicker = !_showColorPicker;
              if (_showColorPicker) _showFontPicker = false;
            }),
            tooltip: "Toggle Colors",
          ),
          IconButton(
            icon: Icon(
              _showSidePanel ? Icons.settings : Icons.settings_outlined,
              color: Colors.white70,
            ),
            onPressed: () => setState(() => _showSidePanel = !_showSidePanel),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: _clearAll,
            tooltip: "Clear Everything",
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green, size: 30),
            onPressed: () => _goLive(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Detect if we are on a vertically constrained device
          final bool isShortScreen = constraints.maxHeight < 600;

          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Added Keyboard-supported Text Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextField(
                        controller: _textController,
                        style: _getAppliedTextStyle(18),
                        decoration: InputDecoration(
                          hintText: "Handwrite below or type...",
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.grey[900],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.backspace_outlined,
                              color: Colors.white54,
                              size: 20,
                            ),
                            onPressed: () => _textController.clear(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white24,
                                width: 2,
                              ),
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkCanvas(
                              key: _canvasKey,
                              onTextRecognized: (result) {
                                if (mounted) {
                                  setState(() {
                                    String currentText = _textController.text;
                                    _textController.text = currentText.isEmpty
                                        ? result
                                        : "$currentText $result";
                                    _canvasKey.currentState?.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          // "Clear Canvas Only" Floating Button
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: FloatingActionButton.small(
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.7,
                              ),
                              onPressed: _clearOnlyCanvas,
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!_isEngineReady)
                            const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.cyanAccent,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Initializing AI Engine...",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_showColorPicker)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: isShortScreen ? 4.0 : 8.0,
                        ),
                        child: ColorEngine(
                          selectedTextColor: _selectedTextColor,
                          selectedBgColor: _selectedBgColor,
                          onTextColorChanged: (color) =>
                              setState(() => _selectedTextColor = color),
                          onBgColorChanged: (color) =>
                              setState(() => _selectedBgColor = color),
                        ),
                      ),
                    if (_showFontPicker)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _fontStyles.length,
                          itemBuilder: (context, index) {
                            final style = _fontStyles[index];
                            final bool isSelected = _selectedFontStyle == style;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(style),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedFontStyle = style);
                                  }
                                },
                                selectedColor: Colors.cyanAccent,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                backgroundColor: Colors.grey[800],
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(
                      height: isShortScreen ? 65 : 80,
                      child: HoverGrid(
                        words: _quickWords,
                        onDelete: (index) => _deleteWord(index),
                        onAdd: _addNewWord,
                        onHover: (word) {
                          if (mounted) {
                            setState(() {
                              _textController.text = word;
                            });
                          }
                        },
                        onTap: (word) => _goLive(overrideText: word),
                        onLongPress: (index, word) => _editWord(index, word),
                      ),
                    ),
                  ],
                ),
              ),
              // Side Panel - only visible if _showSidePanel is true
              if (_showSidePanel)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: 70,
                  color: Colors.grey[850],
                  child: Column(
                    children: [
                      const Icon(Icons.speed, color: Colors.white, size: 20),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: _scrollSpeed,
                            min: 0,
                            max: 10,
                            activeColor: Colors.cyanAccent,
                            onChanged: (val) =>
                                setState(() => _scrollSpeed = val),
                          ),
                        ),
                      ),
                      const Text(
                        "SPEED",
                        style: TextStyle(fontSize: 9, color: Colors.white70),
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      const Icon(
                        Icons.format_size,
                        color: Colors.white,
                        size: 20,
                      ),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: _textSize,
                            min: 50,
                            max: 500,
                            activeColor: Colors.cyanAccent,
                            onChanged: (val) => setState(() => _textSize = val),
                          ),
                        ),
                      ),
                      const Text(
                        "SIZE",
                        style: TextStyle(fontSize: 9, color: Colors.white70),
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      const Icon(
                        Icons.flash_on,
                        color: Colors.amberAccent,
                        size: 20,
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _strobeEnabled,
                          activeThumbColor: Colors.amberAccent,
                          onChanged: (val) =>
                              setState(() => _strobeEnabled = val),
                        ),
                      ),
                      const Text(
                        "STROBE",
                        style: TextStyle(fontSize: 9, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _editWord(int index, String oldWord) {
    TextEditingController editCtrl = TextEditingController(text: oldWord);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Edit Quick-Word",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newWord = editCtrl.text.toUpperCase();
              if (mounted) {
                setState(() {
                  _quickWords[index] = newWord;
                });
              }

              await _storage.saveWords(_quickWords);

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text(
              "SAVE",
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteWord(int index) async {
    if (mounted) {
      setState(() {
        _quickWords.removeAt(index);
      });
    }
    await _storage.saveWords(_quickWords);
  }

  void _addNewWord() {
    TextEditingController addCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Add Quick-Word",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: addCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter word...",
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent),
            ),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (addCtrl.text.isNotEmpty) {
                final newWord = addCtrl.text.trim().toUpperCase();
                if (mounted) {
                  setState(() {
                    _quickWords.add(newWord);
                  });
                }
                await _storage.saveWords(_quickWords);
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text(
              "ADD",
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}
