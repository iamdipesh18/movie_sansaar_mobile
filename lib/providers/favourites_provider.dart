import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_sansaar_mobile/services/favourites_service.dart';
import '../services/auth_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final AuthService authService;
  final FavoritesService favoritesService;

  /// Map of favorite IDs to their types (e.g., 'movie' or 'series')
  Map<String, String> _favoriteMap = {};

  FavoritesProvider({
    required this.authService,
    required FirebaseFirestore firestore,
  }) : favoritesService = FavoritesService(firestore: firestore) {
    _loadFavorites();
    _listenToFavoritesChanges();
  }

  /// Get the map of favorite IDs and their types
  Map<String, String> get favorites => _favoriteMap;

  /// Check if an item (by ID) is favorited
  bool isFavorited(String id) => _favoriteMap.containsKey(id);

  /// Get the type of a favorite by its ID
  String? getType(String id) => _favoriteMap[id];

  /// Load favorites once from Firestore on init
  Future<void> _loadFavorites() async {
    final user = authService.currentUser;
    if (user == null) return;

    final snapshot = await favoritesService.firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    _favoriteMap = {
      for (var doc in snapshot.docs)
        doc.id: (doc.data()['type'] as String?) ?? 'movie',
    };

    notifyListeners();
  }

  /// Listen to Firestore favorites changes in real-time
  void _listenToFavoritesChanges() {
    final user = authService.currentUser;
    if (user == null) return;

    favoritesService.favoritesStream(user.uid).listen((map) {
      _favoriteMap = map;
      notifyListeners();
    });
  }

  /// Add a favorite with optional type (default 'movie')
  Future<void> addFavorite(String id, {String type = 'movie'}) async {
    final user = authService.currentUser;
    if (user == null) return;

    await favoritesService.addFavorite(uid: user.uid, id: id, type: type);
    // The stream listener updates _favoriteMap automatically
  }

  /// Remove a favorite by ID
  Future<void> removeFavorite(String id) async {
    final user = authService.currentUser;
    if (user == null) return;

    await favoritesService.removeFavorite(uid: user.uid, id: id);
    // The stream listener updates _favoriteMap automatically
  }
}
