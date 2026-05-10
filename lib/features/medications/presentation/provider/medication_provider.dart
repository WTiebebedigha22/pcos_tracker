import 'package:flutter/material.dart';

class MedicationProvider extends ChangeNotifier {
  final List<String> medications = [];

  void addMedication(String medication) {
    medications.add(medication);
    notifyListeners();
  }
}