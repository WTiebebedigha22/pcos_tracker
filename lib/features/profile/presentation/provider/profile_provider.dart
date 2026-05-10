import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String username = 'CycleSync User';

  void updateUsername(String value) {
    username = value;
    notifyListeners();
  }
}