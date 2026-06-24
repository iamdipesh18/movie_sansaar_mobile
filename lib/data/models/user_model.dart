class UserModel {
  final String uid;
  final String email;
  final String? fullName;
  final List<String>? favorites;

  const UserModel({
    required this.uid,
    required this.email,
    this.fullName,
    this.favorites,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'],
      favorites: List<String>.from(data['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'fullName': fullName, 'favorites': favorites ?? []};
  }
}
