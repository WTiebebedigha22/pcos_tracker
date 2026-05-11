import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase =
      Supabase.instance.client;

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

  // LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // CURRENT USER
  User? get currentUser =>
      supabase.auth.currentUser;
}