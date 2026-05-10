import 'package:flutter/material.dart';

class SymptomProvider extends ChangeNotifier {
  final List<String> selectedSymptoms = [];

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }

    notifyListeners();
  }
}