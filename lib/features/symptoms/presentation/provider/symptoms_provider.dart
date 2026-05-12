import 'package:flutter/material.dart';

// Model to represent a logged symptom
class SymptomLog {
  final String name;
  final String severity;
  final DateTime time;

  SymptomLog({required this.name, required this.severity, required this.time});
}

class SymptomProvider extends ChangeNotifier {
  final List<String> selectedSymptoms = [];
  
  // This provides the list the Dashboard UI is looking for
  List<SymptomLog> get recentSymptoms => [
    SymptomLog(name: 'Mild Cramps', severity: 'Moderate', time: DateTime.now()),
    SymptomLog(name: 'Bloating', severity: 'Mild', time: DateTime.now()),
  ];

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
    notifyListeners();
  }
}