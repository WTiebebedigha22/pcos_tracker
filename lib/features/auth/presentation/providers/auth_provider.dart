// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
    _currentUser = _supabase.auth.currentUser;
  }

  // LOGIN
  Future<String?> login({
    required String email, 
    required String password
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred. Please try again.';
    }
  }

  // REGISTER - Updated to match your RegisterPage
  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String dob,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'date_of_birth': dob,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred. Please try again.';
    }
  }

  // FORGOT PASSWORD
  Future<String?> resetPassword({
    required String email
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'com.cyclesync.app://reset-password',
      );
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred. Please try again.';
    }
  }

  // UPDATE PASSWORD
  Future<String?> updatePassword({
    required String newPassword
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred. Please try again.';
    }
  }

  // GOOGLE SIGN IN
  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.cyclesync.app://login-callback',
      );
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred with Google Sign In. Please try again.';
    }
  }

  // LOGOUT
  Future<String?> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // HELPER GETTERS
  bool get isLoggedIn => _currentUser != null;
  String? get userName => _currentUser?.userMetadata?['first_name'] as String?;
  String? get userEmail => _currentUser?.email;
}