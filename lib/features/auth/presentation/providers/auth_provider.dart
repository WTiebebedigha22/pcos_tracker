import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(
      const Duration(seconds: 2),
    );

    _isLoading = false;
    notifyListeners();
  }
}