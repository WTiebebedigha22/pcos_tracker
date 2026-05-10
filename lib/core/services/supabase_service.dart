import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client =
      Supabase.instance.client;

  // Auth User
  static User? get currentUser => client.auth.currentUser;

  // Sign Out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}