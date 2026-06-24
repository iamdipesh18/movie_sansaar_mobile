import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/datasources/favorites_api.dart';
import '../../data/repositories/auth_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FavoritesRepository _repository;
  Map<String, String> _favoriteMap = {};

  FavoritesProvider({
    required FirebaseFirestore firestore,
    AuthRepository? authRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _repository = FavoritesRepository(
          api: FavoritesApi(firestore: firestore),
        ) {
    _load();
    _listen();
  }

  Map<String, String> get favorites => _favoriteMap;
  bool isFavorited(String id) => _favoriteMap.containsKey(id);
  String? getType(String id) => _favoriteMap[id];

  Future<void> _load() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    _favoriteMap = {
      for (final doc in snapshot.docs)
        doc.id: (doc.data()['type'] as String?) ?? 'movie',
    };
    notifyListeners();
  }

  void _listen() {
    final user = _authRepository.currentUser;
    if (user == null) return;

    _repository.favoritesStream(user.uid).listen((map) {
      _favoriteMap = map;
      notifyListeners();
    });
  }

  Future<void> addFavorite(String id, {String type = 'movie'}) async {
    final user = _authRepository.currentUser;
    if (user == null) return;
    await _repository.addFavorite(uid: user.uid, id: id, type: type);
  }

  Future<void> removeFavorite(String id) async {
    final user = _authRepository.currentUser;
    if (user == null) return;
    await _repository.removeFavorite(uid: user.uid, id: id);
  }
}
