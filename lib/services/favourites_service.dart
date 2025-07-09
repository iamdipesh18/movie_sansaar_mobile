import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore firestore;

  FavoritesService({required this.firestore});

  /// Add favorite (movie or series)
  /// 'type' defaults to 'movie' if not specified
  Future<void> addFavorite({
    required String uid,
    required String id,
    String type = 'movie', // default value
  }) async {
    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id);
    await docRef.set({
      'id': id,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Remove favorite
  Future<void> removeFavorite({required String uid, required String id}) async {
    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id);
    await docRef.delete();
  }

  /// Check if a favorite exists
  Future<bool> isFavorited({required String uid, required String id}) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .get();
    return doc.exists;
  }

  /// Live stream of favorites as Map<String, String> where key=id, value=type
  Stream<Map<String, String>> favoritesStream(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
          final map = <String, String>{};
          for (final doc in snapshot.docs) {
            final data = doc.data();
            map[doc.id] = (data['type'] as String?) ?? 'movie';
          }
          return map;
        });
  }
}
