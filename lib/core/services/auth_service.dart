import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // REGISTER
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String dob,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'date_of_birth': dob,
      },
    );
  }

  // LOGIN
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // FORGOT PASSWORD - Send password reset email
  Future<void> resetPassword({
    required String email,
  }) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.cyclesync.app://reset-password',
    );
  }

  // UPDATE PASSWORD - After reset or for changing password
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => supabase.auth.currentUser;

  // CHECK IF USER IS LOGGED IN
  bool get isLoggedIn => supabase.auth.currentSession != null;

  // GET AUTH STATE STREAM
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}