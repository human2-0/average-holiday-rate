import 'package:average_holiday_rate_pay/models/settings_model.dart';
import 'package:average_holiday_rate_pay/providers/auth_provider.dart';
import 'package:average_holiday_rate_pay/repository/auth_repository.dart';
import 'package:average_holiday_rate_pay/repository/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSettingsNotifier extends StateNotifier<UserSettingsState> {
  UserSettingsNotifier({required this.authRepository, required this.settingsRepository})
      : super(UserSettingsState());
  final AuthenticationRepository authRepository;
  final SettingsRepository settingsRepository;

  Future<void> fetchUserSettings(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final settings = await settingsRepository.getUserSettings(userId);
      state = state.copyWith(isLoading: false, settings: settings);
    } on FormatException catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserSettings(String userId, Settings newSettings) async {
    try {
      await settingsRepository.createOrUpdateUserSettings(userId,
        newSettings: newSettings,);
      // Update the state with the new or updated settings
      state = state.copyWith(settings: newSettings);
    } on FormatException catch (e) {
      // Handle specific format errors if needed
      state = state.copyWith(error: e.toString());
    }
  }
}
final settingsRepositoryProvider = Provider<SettingsRepository>((ref)=>SettingsRepository());


final userSettingsProvider = StateNotifierProvider.family<UserSettingsNotifier,
    UserSettingsState, String>((ref, userId) {
  final authRepository = ref.watch(authRepositoryProvider);
  final settingsRepository = ref.read(settingsRepositoryProvider);
  return UserSettingsNotifier(authRepository: authRepository, settingsRepository: settingsRepository)
    ..fetchUserSettings(userId);
});
