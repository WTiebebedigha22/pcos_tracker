# Account Lifecycle

- **Email verification:** enable in Supabase Auth → Providers → Email → Confirm email.
- **Password reset:** `resetPasswordForEmail` → deep link `lunora://reset` → `updateUser`.
- **Delete account:** call Edge Function `delete-account` (uses service role) → cascades via FKs.
- **Session refresh:** rely on `supabase_flutter` auto-refresh; listen to `onAuthStateChange`.
