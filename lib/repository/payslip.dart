import 'package:average_holiday_rate_pay/models/payslip.dart'; // Import your Payslip model
import 'package:hive/hive.dart';

class PayslipRepository {
  final String boxName = 'payslips';

  Future<Box<Payslip>> _openBox() async => Hive.openBox<Payslip>(boxName);

  Future<void> addPayslip(Payslip payslip) async {
    final box = await _openBox();
    await box.add(payslip);
  }

  Stream<List<Payslip>> getPayslips() async* {
    final box = await _openBox();
    var payslips = box.values.cast<Payslip?>().whereType<Payslip>().toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    yield payslips; // Emit the sorted list

    // Listen to changes in the box and emit updated lists
    await for (final _ in box.watch()) {
      payslips = box.values.cast<Payslip?>().whereType<Payslip>().toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      yield payslips;
    }
  }
}
