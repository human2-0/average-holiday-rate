import 'package:average_holiday_rate_pay/customs/date_utils.dart';
import 'package:average_holiday_rate_pay/models/payslip.dart';
import 'package:average_holiday_rate_pay/models/settings.dart'; // Adjust the import as necessary
import 'package:hive_flutter/hive_flutter.dart';

class HolidayRateRepository {
  Future<Box<Payslip>> getPayslipBox() async {
    return Hive.openBox<Payslip>('payslips');
  }

  Future<Box<Settings>> _openSettingsBox() async {
    return Hive.openBox<Settings>('settings');
  }

  Future<Settings> _fetchUserSettings(String uid) async {
    final settingsBox = await _openSettingsBox();
    return settingsBox.get(uid) ?? Settings(payRate: 0, contractedHours: 0);
  }

  Future<double> calculateAdjustedHolidayRate(String uid) async {
    final settings = await _fetchUserSettings(uid);
    final hourlyRate = settings.payRate;
    final contractedHours = settings.contractedHours;

    // Initialize variables to store totals
    var totalAverageHours = 0.0;
    var totalAverageBonus = 0.0;

    // Assuming we have a method to fetch payslips for the last 12 months
    final payslips = await fetchPayslipsForLast12MonthsExcludingCurrent();

    for (final payslip in payslips) {
      // Calculate average hours and bonus for each month
      final daysInMonth = DateUtils.getDaysInMonth(
          payslip.startDate.year, payslip.startDate.month,);
      final averageHours = payslip.hoursWorked;
      final averageBonus = payslip
          .bonusesEarned; // Assuming bonuses are already averaged monthly

      // Adjust to weekly averages
      final weeklyAverageHours = (averageHours / daysInMonth) * 365 / 52;
      final weeklyBonusAverage = (averageBonus / daysInMonth) * 365 / 52;

      totalAverageHours += weeklyAverageHours;
      totalAverageBonus += weeklyBonusAverage;
    }

    // Calculate yearly averages
    final yearlyAverageHours = totalAverageHours / 12;
    final yearlyAverageBonus = totalAverageBonus / 12;

    // Adjust the holiday rate based on the yearly averages
    var holidayRate = hourlyRate;
    if (yearlyAverageHours > contractedHours) {
      holidayRate = hourlyRate * (yearlyAverageHours / contractedHours);
    }

    // Calculate bonus per hour
    final averageBonusPerHour = yearlyAverageBonus / yearlyAverageHours;

    // Combine holiday rate with average bonus
    final result = holidayRate + averageBonusPerHour;
    return double.parse(result.toStringAsFixed(2));
  }

  Future<List<Payslip>> fetchPayslipsForLast12MonthsExcludingCurrent() async {
    final payslipBox = await Hive.openBox<Payslip>('payslips');
    final filteredAndSortedPayslips = <Payslip>[];

    // Calculate the start date for the last 12 months period, excluding the current month
    final startOfCurrentMonth =
        DateTime(DateTime.now().year, DateTime.now().month);
    final twelveMonthsAgo = startOfCurrentMonth
        .subtract(const Duration(days: 1))
        .subtract(const Duration(days: 365));

    // Filter payslips within the last 12 months up to the start of the current month
    final allPayslips = payslipBox.values.where(
      (payslip) =>
          payslip.startDate.isAfter(twelveMonthsAgo) &&
          (payslip.startDate.isBefore(startOfCurrentMonth) ||
              payslip.endDate.isBefore(startOfCurrentMonth)),
    );

    // Sort the payslips by startDate in ascending order to process them chronologically
    filteredAndSortedPayslips
      ..addAll(allPayslips)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return filteredAndSortedPayslips;
  }

  Future<Map<String, double>> calculateHistoricalHolidayRates(String uid) async {
    final settings = await _fetchUserSettings(uid);
    final hourlyRate = settings.payRate;
    final contractedHours = settings.contractedHours;

    final payslips = await fetchAllSortedPayslips();

    final historicalHolidayRates = <String, double>{};
    var start = 0; // Start index for each 12-month segment

    // Iterate over payslips and calculate holiday rate for each 12-month segment
    while (start + 12 <= payslips.length) {
      // Ensure there are at least 12 payslips to calculate a segment
      final segmentPayslips = payslips.sublist(start, start + 12);

      // Calculate the holiday rate for the current segment
      final holidayRate = calculateHolidayRateForSegment(segmentPayslips, hourlyRate, contractedHours);

      // Assign this rate to the month following the last payslip in the segment
      final assignmentMonthKey = "${segmentPayslips.last.startDate.year}-${segmentPayslips.last.startDate.month.toString().padLeft(2, '0')}";

      historicalHolidayRates[assignmentMonthKey] = holidayRate;

      start += 1; // Move to the next segment
    }

    return historicalHolidayRates;
  }

  double calculateHolidayRateForSegment(List<Payslip> payslips, double hourlyRate, double contractedHours) {
    // Initialize variables to store totals
    var totalAverageHours = 0.0;
    var totalAverageBonus = 0.0;




    for (final payslip in payslips) {
      final daysInMonth = DateUtils.getDaysInMonth(payslip.startDate.year, payslip.startDate.month);

      final averageHours = payslip.hoursWorked;
      final averageBonus = payslip.bonusesEarned;

      // Adjust to weekly averages
      final weeklyAverageHours = (averageHours / daysInMonth) * 365 / 52;
      final weeklyBonusAverage = (averageBonus / daysInMonth) * 365 / 52;




      totalAverageHours += weeklyAverageHours;
      totalAverageBonus += weeklyBonusAverage;
    }

    // Calculate yearly averages for the segment
    final yearlyAverageHours = totalAverageHours / 12;
    final yearlyAverageBonus = totalAverageBonus / 12;




    // Adjust the holiday rate based on the yearly averages
    var holidayRate = hourlyRate;
    if (yearlyAverageHours > contractedHours) {
      holidayRate = hourlyRate * (yearlyAverageHours / contractedHours);
    }

    final averageBonusPerHour = yearlyAverageHours > 0 ? yearlyAverageBonus / yearlyAverageHours : 0;

    return holidayRate + averageBonusPerHour;
  }

  Future<List<Payslip>> fetchAllSortedPayslips() async {
    final payslipBox = await Hive.openBox<Payslip>('payslips');
    final sortedPayslips = payslipBox.values.toList()

      // Sort payslips by startDate in descending order, handling potential null values
      ..sort((a, b) {
        final aStartDate = a.startDate; // Provide a default if a.startDate is null
        final bStartDate = b.startDate; // Provide a default if b.startDate is null
        return bStartDate.compareTo(aStartDate);
      });

    return sortedPayslips; // Return the sorted list
  }

  DateTime calculateNextMonth(DateTime currentDate) {
    // Directly incrementing the month and handling year transition
    var newYear = currentDate.year;
    var newMonth = currentDate.month + 1;

    // Adjusting for year transition
    if (newMonth > 12) {
      newYear += 1;
      newMonth = 1; // Reset to January for the next year
    }

    // Return the first day of the next month to ensure consistency
    return DateTime(newYear, newMonth);
  }

}
