import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  Size get screenSize => MediaQuery.of(this).size;

  double get screenHeight => screenSize.height;

  double get screenWidth => screenSize.width;

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension DateExtensions on DateTime {
  String formatDate() {
    return "$day/$month/$year";
  }

  bool isToday() {
    final now = DateTime.now();

    return day == now.day &&
        month == now.month &&
        year == now.year;
  }
}