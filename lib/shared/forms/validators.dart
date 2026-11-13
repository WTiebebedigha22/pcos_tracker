/// Inline, on-blur validators. Never validate on every keystroke.
class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v) ? null : 'Invalid email';
  }
  static String? minLength(int n) => (v) =>
      (v == null || v.length < n) ? 'At least $n characters' : null;
}
