
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  if (!value.contains('@')) return 'Invalid email format';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 6) return 'Password must be at least 6 chars';
  return null;
}
