class DateHelpers {
  static String formatDate(
    DateTime date,
  ) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getMonthName(
    int month,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  static int daysBetween(
    DateTime start,
    DateTime end,
  ) {
    return end.difference(start).inDays;
  }

  static bool isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.day == second.day &&
        first.month == second.month &&
        first.year == second.year;
  }

  static DateTime addDays(
    DateTime date,
    int days,
  ) {
    return date.add(
      Duration(days: days),
    );
  }
}