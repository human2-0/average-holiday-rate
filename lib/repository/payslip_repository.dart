import 'package:average_holiday_rate_pay/models/payslip_model.dart'; // Import your Payslip model
import 'package:hive/hive.dart';

class PayslipRepository {
  final String boxName = 'payslips';

  Future<Box<Payslip>> _openBox() async => Hive.openBox<Payslip>(boxName);

  Future<void> addPayslip(Payslip payslip) async {
    final box = await _openBox();
    await box.add(payslip);
  }

  Future<List<Payslip>> getPayslips() async {
    final box =
        await _openBox(); // Assuming _openBox() is defined elsewhere to open your Hive box
    final payslips = box.values.cast<Payslip?>().whereType<Payslip>().toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return payslips;
  }

  Future<void> editPayslip(Payslip updatedPayslip) async {
    final box = await Hive.openBox<Payslip>('payslips');
    // Example: Find the payslip with specific start and end dates
    final payslipKey = box.keys.firstWhere(
      (k) {
        final payslip = box.get(k);
        return payslip?.startDate == updatedPayslip.startDate &&
            payslip?.endDate == updatedPayslip.endDate;
      },
      orElse: () => null,
    );

    if (payslipKey != null) {
      // Found the payslip, now update it with new data
      final payslipToUpdate = box.get(payslipKey);
      if (payslipToUpdate != null) {
        // Assuming you have a method to update fields or you directly set them
        payslipToUpdate
          ..startDate = updatedPayslip.startDate
          ..endDate = updatedPayslip.endDate
          ..basePay = updatedPayslip.basePay
          ..bonusesEarned = updatedPayslip.bonusesEarned
          ..payRate = updatedPayslip.payRate
          ..deductions = updatedPayslip.deductions;
        await payslipToUpdate.save();
      }
    }
  }

  Future<void> removePayslip(Payslip payslip) async {
    final box = await _openBox();

    // Find the key for the payslip to be removed
    final keyToRemove = box.keys.firstWhere(
      (k) => box.get(k) == payslip,
      orElse: () => null,
    );

    // If the payslip is found, delete it
    if (keyToRemove != null) {
      await box.delete(keyToRemove);
    }
  }
}
