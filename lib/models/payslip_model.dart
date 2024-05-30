import 'package:hive/hive.dart';

part 'payslip_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class Payslip extends HiveObject {
  // Total bonuses earned in the pay period

  Payslip({
    required this.startDate,
    required this.endDate,
    required this.basePay,
    required this.bonusesEarned,
    required this.payRate,
    this.deductions,
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
  double basePay; // Total hours worked in the pay period

  @HiveField(3)
  double bonusesEarned;

  @HiveField(4)
  double payRate;

  @HiveField(5)
  double? deductions;

  // Optionally, you can add a method to determine if the payslip is weekly or monthly
  String get periodType {
    final duration = endDate.difference(startDate).inDays;
    if (duration <= 7) {
      return 'Weekly';
    } else {
      return 'Monthly';
    }
  }

  Payslip copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? basePay,
    double? bonusesEarned,
    double? payRate,
    double? deductions,
  }) {
    return Payslip(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      basePay: basePay ?? this.basePay,
      bonusesEarned: bonusesEarned ?? this.bonusesEarned,
      payRate: payRate ?? this.payRate,
      deductions: deductions ?? this.deductions,
    );
  }
}
