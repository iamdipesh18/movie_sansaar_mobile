import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _mapUser(User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName,
    );
  }

  Stream<UserModel?> get userChanges =>
      _auth.authStateChanges().map(_mapUser);

  UserModel? get currentUser => _mapUser(_auth.currentUser);

  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (fullName != null && fullName.isNotEmpty) {
        await credential.user?.updateDisplayName(fullName);
        await credential.user?.reload();
      }

      return _mapUser(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
