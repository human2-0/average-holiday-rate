import 'package:hive/hive.dart';

part 'payslip.g.dart'; // Hive generator

@HiveType(typeId: 0)
class Payslip extends HiveObject { // Total bonuses earned in the pay period

  Payslip({
    required this.startDate,
    required this.endDate,
    required this.hoursWorked,
    required this.bonusesEarned,
  }) {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('endDate cannot be before startDate');
    }
  }
  @HiveField(0)
  DateTime startDate; // Start of the pay period

  @HiveField(1)
  DateTime endDate; // End of the pay period

  @HiveField(2)
  double hoursWorked; // Total hours worked in the pay period

  @HiveField(3)
  double bonusesEarned;

  // Optionally, you can add a method to determine if the payslip is weekly or monthly
  String get periodType {
    final duration = endDate.difference(startDate).inDays;
    if (duration <= 7) {
      return 'Weekly';
    } else {
      return 'Monthly';
    }
  }
}
