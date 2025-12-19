import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/device_model.dart';

class DeviceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> addDevice(DeviceModel device) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final docRef = _db
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(device.deviceId);
      
      await docRef.set(device.toMap(), SetOptions(merge: false));
      
      final savedDoc = await docRef.get();
      return savedDoc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DeviceModel>> getUserDevices() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('devices')
          .get();

      return snapshot.docs
          .map((doc) => DeviceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .get();

      if (!doc.exists) return null;
      return DeviceModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}
