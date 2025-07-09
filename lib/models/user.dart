class UserModel {
  final String uid; // Unique user ID (from Firebase Auth)
  final String email; // Email address
  final String? fullName; // Optional full name
  final List<String>?
  favorites; // List of favorite movie IDs (or other identifiers)

  UserModel({
    required this.uid,
    required this.email,
    this.fullName,
    this.favorites,
  });

  // Optional: Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'],
      favorites: List<String>.from(data['favorites'] ?? []),
    );
  }

  // Optional: Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {'email': email, 'fullName': fullName, 'favorites': favorites ?? []};
  }
}
