class DateService {
  static String formatDate(DateTime date) {
    return
        '${date.day}/${date.month}/${date.year}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return now.day == date.day &&
        now.month == date.month &&
        now.year == date.year;
  }

  static int daysBetween(
    DateTime start,
    DateTime end,
  ) {
    return end.difference(start).inDays;
  }
}