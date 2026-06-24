import '../datasources/favorites_api.dart';

class FavoritesRepository {
  final FavoritesApi _api;

  FavoritesRepository({required FavoritesApi api}) : _api = api;

  Future<void> addFavorite({
    required String uid,
    required String id,
    String type = 'movie',
  }) =>
      _api.addFavorite(uid: uid, id: id, type: type);

  Future<void> removeFavorite({
    required String uid,
    required String id,
  }) =>
      _api.removeFavorite(uid: uid, id: id);

  Future<bool> isFavorited({
    required String uid,
    required String id,
  }) =>
      _api.isFavorited(uid: uid, id: id);

  Stream<Map<String, String>> favoritesStream(String uid) =>
      _api.favoritesStream(uid);
}
