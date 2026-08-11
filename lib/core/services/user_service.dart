import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance.collection("users");

  Future<void> createUser(UserModel user) async {
    await _db.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// บันทึก FCM Token ของ user ลง Firestore
  Future<void> saveFcmToken(String uid, String token) async {
    await _db.doc(uid).set({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
