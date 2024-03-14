import 'package:average_holiday_rate_pay/providers/auth_provider.dart';
import 'package:average_holiday_rate_pay/repository/holiday_rate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HolidayRateState {
  HolidayRateState({required this.holidayRate, this.historicalHolidayRates});
  final double holidayRate;
  final Map<String, double>? historicalHolidayRates;

  HolidayRateState copyWith({
    double? holidayRate,
    Map<String, double>? historicalHolidayRates,
  }) {
    return HolidayRateState(
      holidayRate: holidayRate ?? this.holidayRate,
      historicalHolidayRates:
          historicalHolidayRates ?? this.historicalHolidayRates,
    );
  }
}

class HolidayRateNotifier extends StateNotifier<HolidayRateState> {
  HolidayRateNotifier(this.ref) : super(HolidayRateState(holidayRate: 0));
  final Ref ref;

  Future<void> fetchHistoricalHolidayRates() async {
    try {
      final user = ref.read(authStateNotifierProvider.notifier).state;
      if (user == null) {
        throw Exception('User not logged in.');
      }
      final uid = user.uid;
      final holidayRateRepository = HolidayRateRepository();
      final newHistoricalRates = await holidayRateRepository.calculateHistoricalHolidayRates(uid);
      state = state.copyWith(historicalHolidayRates: newHistoricalRates);
    } on FormatException {
      // Optionally reset historical rates to null or handle error without modifying them
      // state = state.copyWith(historicalHolidayRates: null);
    }
  }
}




final holidayRateNotifierProvider =
    StateNotifierProvider<HolidayRateNotifier, HolidayRateState>((ref) {
  return HolidayRateNotifier(ref);
});

final startIndexProvider = StateProvider<double>((ref) => 0);
