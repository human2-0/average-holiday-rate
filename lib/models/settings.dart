import 'package:hive/hive.dart';

part 'settings.g.dart'; // Hive generator

@HiveType(typeId: 1) // Ensure typeId is unique if you have other Hive types
class Settings extends HiveObject {
  Settings({required this.payRate, required this.contractedHours});

  @HiveField(0)
  final double payRate;

  @HiveField(1)
  final double contractedHours;
}
class UserSettingsState {

  UserSettingsState({this.settings, this.isLoading = false, this.error});
  final Settings? settings;
  final bool isLoading;
  final String? error;

  // A convenient method to copy the current state with updated values
  UserSettingsState copyWith({Settings? settings, bool? isLoading, String? error}) {
    return UserSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }}
