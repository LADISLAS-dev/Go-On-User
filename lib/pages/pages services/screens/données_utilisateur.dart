class UserModel {
  String uid;
  String name;
  String email;
  String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  // Convertir les données depuis/vers Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  static UserModel fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }
}
