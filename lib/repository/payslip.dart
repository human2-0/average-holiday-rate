import 'package:average_holiday_rate_pay/models/payslip.dart'; // Import your Payslip model
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
