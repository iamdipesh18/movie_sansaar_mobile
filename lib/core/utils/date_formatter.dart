class DateFormatter {
  DateFormatter._();

  static String extractYear(String date) {
    if (date.isEmpty || !date.contains('-')) return '';
    return date.split('-')[0];
  }

  static String formatRuntime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
