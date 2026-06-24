import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesApi {
  final FirebaseFirestore firestore;

  FavoritesApi({required this.firestore});

  Future<void> addFavorite({
    required String uid,
    required String id,
    String type = 'movie',
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .set({
      'id': id,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite({
    required String uid,
    required String id,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .delete();
  }

  Future<bool> isFavorited({
    required String uid,
    required String id,
  }) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .get();
    return doc.exists;
  }

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
