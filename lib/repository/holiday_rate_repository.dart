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

  Future<Map<String, double>> calculateHistoricalHolidayRates(String uid) async {
    print('Starting calculation of historical holiday rates for UID: $uid');
    final settings = await _fetchUserSettings(uid);
    final payslips = await fetchAllSortedPayslips();

    if (payslips.isEmpty) {
      print('No payslips found. Returning empty holiday rate map.');
      return {}; // Return an empty map or a map with a default value
    }

    final historicalHolidayRates = <String, double>{};
    var start = 0; // Start index for each 12-month segment

    while (start + 12 <= payslips.length) {
      final segmentPayslips = payslips.sublist(start, start + 12);
      final monthName = DateUtils.getMonthName(segmentPayslips.last.startDate.month);
      print('Calculating holiday rate for segment of 12 months for month $monthName');

      final holidayRate = calculateHolidayRateForSegment(
        start,
        segmentPayslips,
        settings.contractedHours,
        settings,
      );

      final assignmentMonthKey = '${segmentPayslips.last.startDate.year}-${segmentPayslips.last.startDate.month}';
      historicalHolidayRates[assignmentMonthKey] = holidayRate;
      print('----------------------------');

      print('Holiday rate for $assignmentMonthKey: ${holidayRate.toStringAsFixed(2)}');

      start += 1;
    }

    return historicalHolidayRates;
  }

  double calculateHolidayRateForSegment(
      int start,
      List<Payslip> payslips,
      double contractedHours,
      Settings settings,
      ) {
    var totalAverageHours = 0.0;
    var totalAverageBonus = 0.0;
    var index =1;


    for (final payslip in payslips) {
      final daysInMonth = DateUtils.getDaysInMonth(
        payslip.startDate.year,
        payslip.startDate.month,
      );

      print('$index out of ${payslips.length}');
      print('Payslip ${DateUtils.getMonthName(payslip.startDate.month)} ${payslip.startDate.year}');
      print('Payslip data:\n Base pay: ${payslip.basePay}\n Payrate: ${payslip.payRate}\n Bonus earned this month: ${payslip.bonusesEarned}');


      final averageHours = (payslip.basePay - (payslip.deductions == null ? 0 : payslip.deductions!)) / payslip.payRate;
      final averageBonus = payslip.bonusesEarned;

      print('base pay divided by pay rate gives average hours of: ${averageHours.toStringAsFixed(2)}');

      final weeklyAverageHours = (averageHours / daysInMonth) * 365 / 52;
      final weeklyBonusAverage = (averageBonus / daysInMonth) * 365 / 52;
      print('average hours divided by days in month [$daysInMonth], and multiplied by days in year [365], and divided by amount of weeks in a year[52] gives weekly average bonus of $weeklyAverageHours');
      print('bonus earned divided by days in month [$daysInMonth], and multiplied by days in year [365], and divided by amount of weeks in a year[52] gives weekly average bonus of $weeklyBonusAverage');

      totalAverageHours += weeklyAverageHours;
      totalAverageBonus += weeklyBonusAverage;
      index += 1;
    }
    print('sum of weekly average hours for last 12 eligible payslips: $totalAverageHours');
    print('sum of weekly average bonus for last 12 eligible payslips: $totalAverageBonus');

    final yearlyAverageHours = totalAverageHours / 12;
    final yearlyAverageBonus = totalAverageBonus / 12;

    print('yearly average weekly hours (sum of all weekly average hours from each month divided by 12): $yearlyAverageHours');
    print('yearly average weekly bonus (sum of all weekly average hours from each month divided by 12): $yearlyAverageBonus');

    var holidayRate = payslips[start].payRate;
    print('as per formula, if yearly average hours ${yearlyAverageHours.toStringAsFixed(2)} is below contracted hours [$contractedHours], adjust accordingly');
    if (yearlyAverageHours > contractedHours) {
      holidayRate = holidayRate * (yearlyAverageHours / contractedHours);
    }

    final averageBonusPerHour = yearlyAverageHours > 0 ? yearlyAverageBonus / yearlyAverageHours : 0;

    print('Calculated holiday rate: ${holidayRate.toStringAsFixed(2)} with bonus per hour ${averageBonusPerHour.toStringAsFixed(2)}');

    return holidayRate + averageBonusPerHour;
  }

  Future<List<Payslip>> fetchAllSortedPayslips() async {
    print('Fetching and sorting all payslips.');
    final payslipBox = await Hive.openBox<Payslip>('payslips');
    final sortedPayslips = payslipBox.values.toList()
      ..sort((a, b) {
        final aStartDate = a.startDate;
        final bStartDate = b.startDate;
        return bStartDate.compareTo(aStartDate);
      });

    print('Sorted ${sortedPayslips.length} payslips by startDate.');
    return sortedPayslips;
  }
}
