import 'package:average_holiday_rate_pay/models/payslip.dart';
import 'package:average_holiday_rate_pay/repository/payslip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final payslipRepositoryProvider = Provider<PayslipRepository>((ref) => PayslipRepository());

final payslipStreamProvider = StreamProvider.autoDispose<List<Payslip>>((ref) {
  final repository = ref.read(payslipRepositoryProvider);
  return repository.getPayslips();
});
