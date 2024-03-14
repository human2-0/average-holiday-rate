import 'package:average_holiday_rate_pay/customs/date_utils.dart';
import 'package:average_holiday_rate_pay/models/payslip_model.dart';
import 'package:average_holiday_rate_pay/models/settings_model.dart'; // Adjust the import as necessary
import 'package:hive_flutter/hive_flutter.dart';

class HolidayRateRepository {
  Future<Box<Settings>> _openSettingsBox() async {
    return Hive.openBox<Settings>('settings');
  }

  Future<Settings> _fetchUserSettings(String uid) async {
    final settingsBox = await _openSettingsBox();
    return settingsBox.get(uid) ?? Settings(payRate: 0, contractedHours: 0);
  }

  Future<Map<String, double>> calculateHistoricalHolidayRates(
    String uid,
  ) async {
    final settings = await _fetchUserSettings(uid);
    final contractedHours = settings.contractedHours;

    final payslips = await fetchAllSortedPayslips();

    if (payslips.isEmpty) {
      return {}; // Return an empty map or a map with a default value
    }

    final historicalHolidayRates = <String, double>{};
    var start = 0; // Start index for each 12-month segment

    // Iterate over payslips and calculate holiday rate for each 12-month segment
    while (start + 12 <= payslips.length) {
      // Ensure there are at least 12 payslips to calculate a segment
      final segmentPayslips = payslips.sublist(start, start + 12);

      // Calculate the holiday rate for the current segment
      final holidayRate = calculateHolidayRateForSegment(
        start,
        segmentPayslips,
        contractedHours,
        settings,
      );

      // Assign this rate to the month following the last payslip in the segment
      final assignmentMonthKey =
          "${segmentPayslips.last.startDate.year}-${segmentPayslips.last.startDate.month.toString().padLeft(2, '0')}";

      historicalHolidayRates[assignmentMonthKey] = holidayRate;

      start += 1; // Move to the next segment
    }

    return historicalHolidayRates;
  }

  double calculateHolidayRateForSegment(
    int start,
    List<Payslip> payslips,
    double contractedHours,
    Settings settings,
  ) {
    // Initialize variables to store totals
    var totalAverageHours = 0.0;
    var totalAverageBonus = 0.0;

    for (final payslip in payslips) {
      final daysInMonth = DateUtils.getDaysInMonth(
        payslip.startDate.year,
        payslip.startDate.month,
      );

      final averageHours = payslip.basePay / payslip.payRate;
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
    // print('total avarage hours $yearlyAverageHours');
    // print('bonusper week avarage yearly $yearlyAverageBonus');

    // Adjust the holiday rate based on the yearly averages
    var holidayRate = payslips[start].payRate;
    if (yearlyAverageHours > contractedHours) {
      holidayRate = holidayRate * (yearlyAverageHours / contractedHours);
    }

    final averageBonusPerHour =
        yearlyAverageHours > 0 ? yearlyAverageBonus / yearlyAverageHours : 0;
    // print('final bonus $averageBonusPerHour');

    return holidayRate + averageBonusPerHour;
  }

  Future<List<Payslip>> fetchAllSortedPayslips() async {
    final payslipBox = await Hive.openBox<Payslip>('payslips');
    final sortedPayslips = payslipBox.values.toList()

      // Sort payslips by startDate in descending order, handling potential null values
      ..sort((a, b) {
        final aStartDate =
            a.startDate; // Provide a default if a.startDate is null
        final bStartDate =
            b.startDate; // Provide a default if b.startDate is null
        return bStartDate.compareTo(aStartDate);
      });

    return sortedPayslips; // Return the sorted list
  }
}
