import 'package:average_holiday_rate_pay/models/settings.dart';
import 'package:average_holiday_rate_pay/repository/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStateNotifier extends StateNotifier<User?> {
  AuthStateNotifier(this._authRepo) : super(_authRepo.currentUser) {
    _authRepo.authStateChanges.listen((user) {
      state = user;
    });
  }
  final AuthenticationRepository _authRepo;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password,) async {
    return _authRepo.signInWithEmailAndPassword(email, password);
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password,) async {
    return _authRepo.signUpWithEmailAndPassword(email, password);
  }

  Future<UserCredential> signInWithGoogle() async {
    return _authRepo.signInWithGoogle();
  }

  Future<void> linkCredentialsWithGoogle(String email, String password) async {
    try {
      await _authRepo.linkEmailPasswordCredentials(email, password);

      state = _authRepo.currentUser;
    } on FormatException catch (e) {
      ScaffoldMessenger(child: Text(e.message));
    }
  }


  Future<void> signOut() async {
    await _authRepo.signOut();
  }
}

final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

final authRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  return AuthenticationRepository();
});

class UserSettingsNotifier extends StateNotifier<UserSettingsState> {

  UserSettingsNotifier({required this.authRepository}) : super(UserSettingsState());
  final AuthenticationRepository authRepository;

  Future<void> fetchUserSettings(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final settings = await authRepository.getUserSettings(userId);
      state = state.copyWith(isLoading: false, settings: settings);
    } on FormatException catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserSettings(String userId, Settings newSettings) async {
    try {
      await authRepository.createOrUpdateUserSettings(userId, newSettings: newSettings);
      // Update the state with the new or updated settings
      state = state.copyWith(settings: newSettings);
    } on FormatException catch (e) {
      // Handle specific format errors if needed
      state = state.copyWith(error: e.toString());
    }
  }
}

// Step 3: Use StateNotifierProvider
final userSettingsProvider = StateNotifierProvider.family<UserSettingsNotifier, UserSettingsState, String>((ref, userId) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UserSettingsNotifier(authRepository: authRepository)..fetchUserSettings(userId);
});
