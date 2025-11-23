class UserModel {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final List<String> partiesCreated;
  final List<String> partiesJoined;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.partiesCreated,
    required this.partiesJoined,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'partiesCreated': partiesCreated,
      'partiesJoined': partiesJoined,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      partiesCreated: List<String>.from(map['partiesCreated'] ?? []),
      partiesJoined: List<String>.from(map['partiesJoined'] ?? []),
    );
  }
}
