import 'package:flutter/material.dart';

class CycleProvider extends ChangeNotifier {
  DateTime? selectedDate;

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }
}