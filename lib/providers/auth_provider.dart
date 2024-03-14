import 'package:average_holiday_rate_pay/repository/auth_repository.dart';
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
    String email,
    String password,
  ) async {
    return _authRepo.signInWithEmailAndPassword(email, password);
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
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

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

final authRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  return AuthenticationRepository();
});
