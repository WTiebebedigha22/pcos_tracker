import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int cycleDay = 12;
  int waterIntake = 4;
  bool _isLoading = false;

  // Getters that match your UI calls
  int get currentCycleDay => cycleDay;
  bool get isLoading => _isLoading;

  void updateWaterIntake() {
    waterIntake++;
    notifyListeners();
  }

  // Required for the RefreshIndicator in DashboardPage
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate a network fetch from Supabase
      await Future.delayed(const Duration(seconds: 1));
      // Logic to refresh data would go here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}