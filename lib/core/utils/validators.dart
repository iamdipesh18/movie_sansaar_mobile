class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? Function(String?) minLength(int min) => (String? value) {
        if (value == null || value.length < min) {
          return 'Minimum $min characters';
        }
        return null;
      };

  static String? match(String? value, String other, String label) {
    if (value != other) return '$label doesn\'t match';
    return null;
  }
}
