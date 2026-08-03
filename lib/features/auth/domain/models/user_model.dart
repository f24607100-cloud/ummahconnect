class UserModel {
  final String uid;
  final String email;
  final String name;
  final String country;
  final String city;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.country,
    required this.city,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'country': country,
      'city': city,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? country,
    String? city,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
