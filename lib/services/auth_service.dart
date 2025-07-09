import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_sansaar_mobile/models/user.dart'; // Your custom user model

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User to your UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName,
    );
  }

  // Stream for auth state changes
  Stream<UserModel?> get userChanges =>
      _auth.authStateChanges().map(_userFromFirebaseUser);

  // Sign up new user
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (fullName != null && fullName.isNotEmpty) {
        await credential.user?.updateDisplayName(fullName);
        await credential.user?.reload();
      }

      return _userFromFirebaseUser(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (signUp): ${e.message}');
      return null;
    } catch (e) {
      print('General SignUp Error: $e');
      return null;
    }
  }

  // Sign in existing user
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (signIn): ${e.message}');
      return null;
    } catch (e) {
      print('General SignIn Error: $e');
      return null;
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('SignOut Error: $e');
    }
  }

  // Get currently signed-in user synchronously
  UserModel? get currentUser => _userFromFirebaseUser(_auth.currentUser);
}
