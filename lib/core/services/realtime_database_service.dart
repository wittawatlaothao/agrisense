import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/models/sensor_data_model.dart';
import '../../data/models/dashboard_config_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://agrisense-65a36-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  /// Get a stream of sensor data for a specific device
  Stream<SensorDataModel?> getDeviceDataStream(String deviceId) {
    final deviceRef = _database.ref('boards/$deviceId');
    
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
      final deviceRef = _database.ref('boards/$deviceId');
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
      // อัปเดทที่ config/devices/{controlName}/control/manual_state แทน
      final manualStateRef = _database.ref('boards/$deviceId/config/devices/$controlName/control/manual_state');
      await manualStateRef.set(value);
      
      // Update lastUpdate timestamp
      final lastUpdateRef = _database.ref('boards/$deviceId/lastUpdate');
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
      final deviceRef = _database.ref('boards/$deviceId');
      final snapshot = await deviceRef.get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get all devices (useful for listing)
  Future<List<String>> getAllDeviceIds() async {
    try {
      final devicesRef = _database.ref('boards');
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

  /// Get dashboard configuration for a device
  Future<DashboardConfigModel> getDeviceConfig(String deviceId) async {
    try {
      final configRef = _database.ref('boards/$deviceId/config');
      final snapshot = await configRef.get();
      
      if (!snapshot.exists) {
        // Return default config if not found
        return DashboardConfigModel.defaultConfig();
      }
      
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return DashboardConfigModel.defaultConfig();
      }
      
      return DashboardConfigModel.fromMap(data);
    } catch (e) {
      print('Error fetching device config: $e');
      return DashboardConfigModel.defaultConfig();
    }
  }

  /// Get dashboard configuration stream
  Stream<DashboardConfigModel> getDeviceConfigStream(String deviceId) {
    final configRef = _database.ref('boards/$deviceId/config');
    
    return configRef.onValue.map((event) {
      if (!event.snapshot.exists) {
        return DashboardConfigModel.defaultConfig();
      }
      
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return DashboardConfigModel.defaultConfig();
      }
      
      return DashboardConfigModel.fromMap(data);
    });
  }

  /// Update sensor configuration
  Future<bool> updateSensorConfig(
    String deviceId,
    String sensorKey, {
    required String title,
    required String unit,
    required String icon,
    required String color,
    required int order,
  }) async {
    try {
      final sensorRef = _database.ref('boards/$deviceId/config/sensors/$sensorKey');
      await sensorRef.update({
        'title': title,
        'unit': unit,
        'icon': icon,
        'color': color,
        'order': order,
      });
      return true;
    } catch (e) {
      print('Error updating sensor config: $e');
      return false;
    }
  }

  /// Update device configuration
  Future<bool> updateDeviceConfig(
    String deviceId,
    String deviceKey, {
    required String title,
    required String icon,
    required String color,
    required int order,
    required String controlMode,
    required bool enabled,
  }) async {
    try {
      final deviceRef = _database.ref('boards/$deviceId/config/devices/$deviceKey');
      await deviceRef.update({
        'title': title,
        'icon': icon,
        'color': color,
        'order': order,
        'enabled': enabled,
        'control': {
          'mode': controlMode,
        },
      });
      return true;
    } catch (e) {
      print('Error updating device config: $e');
      return false;
    }
  }
}
