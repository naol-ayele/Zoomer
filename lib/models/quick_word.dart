class QuickWord {
  final String label;
  final String value;

  QuickWord({required this.label, required this.value});

  // Convert a QuickWord object into a Map to save in SharedPreferences
  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  // Convert a Map from SharedPreferences back into a QuickWord object
  factory QuickWord.fromJson(Map<String, dynamic> json) {
    return QuickWord(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }
}
