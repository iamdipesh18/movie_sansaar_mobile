import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _repository.userChanges.listen((user) {
      _user = user;
      _error = null;
      notifyListeners();
    });
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.signIn(email: email, password: password);
      _user = user;
      return user != null;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      _user = user;
      return user != null;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }
}
