import 'package:flutter/material.dart';

class LifestyleProvider extends ChangeNotifier {
  int waterGlasses = 0;

  void addWater() {
    waterGlasses++;
    notifyListeners();
  }
}