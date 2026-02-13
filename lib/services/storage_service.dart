import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'zoomer_quick_words';

  // Save the list of custom words to memory [cite: 65]
  Future<void> saveWords(List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, words);
  }

  // Retrieve saved words or return defaults if empty
  Future<List<String>> loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? ["YES", "NO", "WAIT", "STOP"];
  }
}
