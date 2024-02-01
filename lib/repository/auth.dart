import 'package:average_holiday_rate_pay/models/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _handleUserAfterAuthentication(
    UserCredential userCredential,
  ) async {
    if (userCredential.user != null) {
      await createOrUpdateUserSettings(userCredential.user!.uid);
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

  Future<void> createOrUpdateUserSettings(String userId,
      {Settings? newSettings,}) async {
    final settingsBox = await Hive.openBox<Settings>('settings');

    final settingsToSave =
        newSettings ?? Settings(contractedHours: 0, payRate: 0);
    // Perform the creation or update
    await settingsBox.put(userId, settingsToSave);
  }

  Future<Settings> getUserSettings(String userId) async {
    final settingsBox = await Hive.openBox<Settings>('settings');
    return settingsBox.get(userId,
        defaultValue: Settings(payRate: 0, contractedHours: 0),)!;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Get the current user
}
