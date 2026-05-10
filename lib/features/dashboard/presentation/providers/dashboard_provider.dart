import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int cycleDay = 12;
  int waterIntake = 4;

  void updateWaterIntake() {
    waterIntake++;
    notifyListeners();
  }
}