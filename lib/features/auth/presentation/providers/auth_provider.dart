import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService =
      AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // REGISTER
  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String dob,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        password: password,
        dob: dob,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.login(
        email: email,
        password: password,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}