import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/models/sensor_data_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://agrisense-65a36-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  /// Get a stream of sensor data for a specific device
  Stream<SensorDataModel?> getDeviceDataStream(String deviceId) {
    final deviceRef = _database.ref('devices/$deviceId');
    
    return deviceRef.onValue.map((event) {
      if (!event.snapshot.exists) {
        return null;
      }
      
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return null;
      }
      
      return SensorDataModel.fromMap(data);
    });
  }

  /// Get a single snapshot of device data
  Future<SensorDataModel?> getDeviceData(String deviceId) async {
    try {
      final deviceRef = _database.ref('devices/$deviceId');
      final snapshot = await deviceRef.get();
      
      if (!snapshot.exists) {
        return null;
      }
      
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return null;
      }
      
      return SensorDataModel.fromMap(data);
    } catch (e) {
      print('Error fetching device data: $e');
      return null;
    }
  }

  /// Update device control (LED, water pump, etc.)
  Future<bool> updateDeviceControl(String deviceId, String controlName, bool value) async {
    try {
      final controlRef = _database.ref('devices/$deviceId/devices/$controlName');
      await controlRef.set(value);
      
      // Update lastUpdate timestamp
      final lastUpdateRef = _database.ref('devices/$deviceId/lastUpdate');
      await lastUpdateRef.set(DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      print('Error updating device control: $e');
      return false;
    }
  }

  /// Update LED status
  Future<bool> updateLED(String deviceId, bool isOn) async {
    return updateDeviceControl(deviceId, 'led', isOn);
  }

  /// Update water pump status
  Future<bool> updateWaterPump(String deviceId, bool isOn) async {
    return updateDeviceControl(deviceId, 'water_pump', isOn);
  }

  /// Check if device exists
  Future<bool> deviceExists(String deviceId) async {
    try {
      final deviceRef = _database.ref('devices/$deviceId');
      final snapshot = await deviceRef.get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get all devices (useful for listing)
  Future<List<String>> getAllDeviceIds() async {
    try {
      final devicesRef = _database.ref('devices');
      final snapshot = await devicesRef.get();
      
      if (!snapshot.exists) {
        return [];
      }
      
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return [];
      }
      
      return data.keys.map((key) => key.toString()).toList();
    } catch (e) {
      print('Error fetching device IDs: $e');
      return [];
    }
  }
}
