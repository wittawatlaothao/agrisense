class UserModel {
  final String uid;
  final String email;

  UserModel({
    required this.uid,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "email": email,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"],
      email: map["email"],
    );
  }
}
