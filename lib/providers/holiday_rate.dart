import 'package:average_holiday_rate_pay/providers/auth.dart';
import 'package:average_holiday_rate_pay/repository/holiday_rate.dart';
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
      historicalHolidayRates: historicalHolidayRates ?? this.historicalHolidayRates,
    );
  }
}


class HolidayRateNotifier extends StateNotifier<HolidayRateState> {

  HolidayRateNotifier(this.ref) : super(HolidayRateState(holidayRate: 0));
  final Ref ref;

  Future<void> calculateAverageHolidayRate({String? baseDate}) async {
    final user = ref.read(authStateNotifierProvider.notifier).state;
    // Ensure there is a user before proceeding
    if (user == null) {
      throw Exception('User not logged in.');
    }
    final uid = user.uid; // Now it's safe to access uid

    final holidayRateRepository = HolidayRateRepository(); // Assuming this is instantiated here or retrieved from the ref if provided

    final holidayRate = await holidayRateRepository.calculateAdjustedHolidayRate(uid);
    state = HolidayRateState(holidayRate: holidayRate);
  }

  Future<void> fetchHistoricalHolidayRates() async {
    final user = ref.read(authStateNotifierProvider.notifier).state;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    final uid = user.uid;
    final holidayRateRepository = HolidayRateRepository();
    final newHistoricalRates = await holidayRateRepository.calculateHistoricalHolidayRates(uid);
    state = state.copyWith(historicalHolidayRates: newHistoricalRates);
  }
}

final holidayRateNotifierProvider = StateNotifierProvider<HolidayRateNotifier, HolidayRateState>((ref) {
  return HolidayRateNotifier(ref);
});

final startIndexProvider = StateProvider<double>((ref)=>0);
