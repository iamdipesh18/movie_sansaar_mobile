import '../models/user_model.dart';
import '../datasources/auth_api.dart';

class AuthRepository {
  final AuthApi _api;

  AuthRepository({AuthApi? api}) : _api = api ?? AuthApi();

  Stream<UserModel?> get userChanges => _api.userChanges;

  UserModel? get currentUser => _api.currentUser;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) =>
      _api.signUp(email: email, password: password, fullName: fullName);

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) =>
      _api.signIn(email: email, password: password);

  Future<void> signOut() => _api.signOut();
}
