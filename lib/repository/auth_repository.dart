import 'package:average_holiday_rate_pay/repository/settings_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _handleUserAfterAuthentication(
    UserCredential userCredential,
  ) async {
    if (userCredential.user != null) {
      await _settingsRepository.createOrUpdateUserSettings(userCredential.user!.uid);
    }
  }

  // Email and Password Sign In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _handleUserAfterAuthentication(userCredential);
    return userCredential;
  }

  // Email and Password Sign Up
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _handleUserAfterAuthentication(userCredential);
    return userCredential;
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await _handleUserAfterAuthentication(userCredential);

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> linkEmailPasswordCredentials(
    String email,
    String password,
  ) async {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    return _firebaseAuth.currentUser!.linkWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Get the current user
}
