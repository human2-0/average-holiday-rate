import 'package:average_holiday_rate_pay/models/payslip.dart';
import 'package:average_holiday_rate_pay/repository/payslip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final payslipRepositoryProvider = Provider<PayslipRepository>((ref) => PayslipRepository());

// final payslipStreamProvider = StreamProvider.autoDispose<List<Payslip>>((ref) {
//   final repository = ref.read(payslipRepositoryProvider);
//   return repository.getPayslips();
// });

class PayslipNotifier extends StateNotifier<List<Payslip>> {

  PayslipNotifier(this.repository) : super([]) {
    Future.microtask(() async => _fetchPayslips());
  }
  final PayslipRepository repository;

  Future<void> _fetchPayslips() async {
    try {
      // Await the future here
      final payslips = await repository.getPayslips();
      state = payslips;
    } on FormatException catch (e) {
      // Handle exceptions or errors accordingly
      if (kDebugMode) {
        print('Error fetching payslips: $e');
      }
    }
  }

  Future<void> addPayslip(Payslip payslip) async {
    try {
      await repository.addPayslip(payslip);
      // Fetch the updated list of payslips and update the state
      final updatedPayslips = await repository.getPayslips();
      state = updatedPayslips;
    } on FormatException catch (e) {
      // Handle any errors here
      if (kDebugMode) {
        print('Error adding payslip: $e');
      }
    }
  }

  Future<void> removePayslip(Payslip payslip, int index) async {
    try {
      await repository.removePayslip(payslip);
      // Remove the payslip from the current state list
      state = [
        ...state.where((element) => element != payslip),
      ];
    } on FormatException catch (e) {
      // Handle any errors here
      if (kDebugMode) {
        print('Error removing payslip: $e');
      }
    }
  }


}

final payslipNotifierProvider = StateNotifierProvider<PayslipNotifier, List<Payslip>>((ref) {
  final repository = ref.read(payslipRepositoryProvider);
  return PayslipNotifier(repository);
});
