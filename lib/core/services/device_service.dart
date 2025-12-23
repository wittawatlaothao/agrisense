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

      // 1. บันทึกใน subcollection: users/{userId}/devices/{deviceId}
      final userDeviceRef = _db
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(device.deviceId);

      // 2. บันทึกใน top-level collection: devices/{deviceId}
      final globalDeviceRef = _db.collection('devices').doc(device.deviceId);

      // เตรียมข้อมูลแยกกัน
      final userDeviceData = {
        'deviceId': device.deviceId,
        'deviceName': device.deviceName,
        'createdAt': device.createdAt.toIso8601String(),
        // ไม่เก็บ userId ใน subcollection
      };

      final globalDeviceData = {
        'deviceId': device.deviceId,
        'deviceName': device.deviceName,
        'userId': userId, // เก็บ userId เฉพาะใน top-level collection
        'createdAt': device.createdAt.toIso8601String(),
      };

      // Batch write เพื่อให้ทั้ง 2 ที่สำเร็จพร้อมกัน
      final batch = _db.batch();
      batch.set(userDeviceRef, userDeviceData);
      batch.set(globalDeviceRef, globalDeviceData);
      
      await batch.commit();

      // Verify
      final savedDoc = await userDeviceRef.get();
      return savedDoc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // Query จาก subcollection (devices ของ user เฉพาะ)
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

  // Query จาก top-level collection (device โดยตรง)
  Future<DeviceModel?> getDeviceById(String deviceId) async {
    try {
      final doc = await _db.collection('devices').doc(deviceId).get();
      if (!doc.exists) return null;
      return DeviceModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
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
