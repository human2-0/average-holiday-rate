class DateUtils {
  late int year;
  late int month;
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Returns the number of days in a given month (and year).
  ///
  /// Parameters:
  ///   [year]: The year as an integer.
  ///   [month]: The month as an integer, where January is 1 and December is 12.
  ///
  /// Returns:
  ///   The number of days in the month.
  static int getDaysInMonth(int year, int month) {
    // Dart DateTime months are 1-based, and for the day parameter, 0 means the last day of the previous month.
    // So, to get the last day of the intended month, create a DateTime for the first day of the next month,
    // then use the day 0 constructor to find the last day of the intended month.
    return DateTime(year, month + 1, 0).day;
  }

  /// Returns the name of the month for a given month number.
  ///
  /// Parameters:
  ///   [month]: The month as an integer, where January is 1 and December is 12.
  ///
  /// Returns:
  ///   The name of the month.

  static String getMonthName(int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    return _monthNames[month - 1];
  }
}
