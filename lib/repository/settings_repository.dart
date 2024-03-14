import 'package:average_holiday_rate_pay/models/settings_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  Future<void> createOrUpdateUserSettings(
    String userId, {
    Settings? newSettings,
  }) async {
    // Open the Hive box for settings
    final settingsBox = await Hive.openBox<Settings>('settings');

    // Attempt to fetch existing user settings
    final existingSettings = await getUserSettings(userId);

    // Determine which settings to save
    Settings settingsToSave;

    if (newSettings != null) {
      // If newSettings is provided, use it
      settingsToSave = newSettings;
    } else {
      settingsToSave = existingSettings;
    }
    // Perform the save operation
    await settingsBox.put(userId, settingsToSave);
  }

  Future<Settings> getUserSettings(String userId) async {
    final settingsBox = await Hive.openBox<Settings>('settings');
    return settingsBox.get(
      userId,
      defaultValue: Settings(payRate: 0, contractedHours: 0),
    )!;
  }
}
