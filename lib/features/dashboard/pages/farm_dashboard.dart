import 'package:agrisense/core/services/realtime_database_service.dart';
import 'package:agrisense/core/utils/icon_helper.dart';
import 'package:agrisense/data/models/sensor_data_model.dart';
import 'package:agrisense/data/models/dashboard_config_model.dart';
import 'package:agrisense/features/dashboard/pages/device_card.dart';
import 'package:agrisense/features/dashboard/pages/sensor_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmDashboard extends StatelessWidget {
  final String farmId;
  final RealtimeDatabaseService _realtimeService = RealtimeDatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FarmDashboard({super.key, required this.farmId});

  Stream<DashboardConfigModel> _getConfigFromFirestore() {
    return _firestore
        .collection('sensors')
        .where('boardId', isEqualTo: farmId)
        .snapshots()
        .asyncMap((sensorSnapshot) async {
      final deviceSnapshot = await _firestore
          .collection('devices')
          .where('boardId', isEqualTo: farmId)
          .get();

      final sensors = sensorSnapshot.docs.map((doc) {
        final data = doc.data();
        return SensorConfig(
          key: data['sensorType'] ?? 'unknown',
          title: data['title'] ?? '',
          unit: data['unit'] ?? '',
          icon: data['icon'] ?? 'sensors',
          color: data['color'] ?? 'blue',
          order: (data['order'] is int) ? data['order'] : 0,
        );
      }).toList();

      final devices = deviceSnapshot.docs.map((doc) {
        final data = doc.data();
        return DeviceConfig(
          key: data['deviceType'] ?? 'unknown',
          title: data['title'] ?? '',
          icon: data['icon'] ?? 'power',
          color: data['color'] ?? 'blue',
          order: (data['order'] is int) ? data['order'] : 0,
          enabled: true,
          controlMode: 'manual',
        );
      }).toList();

      return DashboardConfigModel(
        sensors: sensors,
        devices: devices,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardConfigModel>(
      stream: _getConfigFromFirestore(),
      builder: (context, configSnapshot) {
        // Show loading while waiting for config
        if (configSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error if config fails
        if (configSnapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('เกิดข้อผิดพลาดในการโหลด config: ${configSnapshot.error}'),
              ],
            ),
          );
        }

        final config = configSnapshot.data ?? DashboardConfigModel.defaultConfig();

        return StreamBuilder<SensorDataModel?>(
          stream: _realtimeService.getDeviceDataStream(farmId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger rebuild
                        (context as Element).markNeedsBuild();
                      },
                      child: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data;

            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.device_unknown, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('ไม่พบข้อมูลอุปกรณ์ $farmId'),
                    const SizedBox(height: 8),
                    const Text(
                      'โปรดตรวจสอบว่าอุปกรณ์เชื่อมต่ออยู่',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Sort sensors and devices by order
            final sortedSensors = List<SensorConfig>.from(config.sensors)
              ..sort((a, b) => a.order.compareTo(b.order));
            final sortedDevices = List<DeviceConfig>.from(config.devices)
              ..sort((a, b) => a.order.compareTo(b.order));

            // Build cards dynamically
            final List<Widget> cards = [];

            // Add sensor cards
            for (var sensorConfig in sortedSensors) {
              final rawValue = _getSensorValue(data.sensors, sensorConfig.key);
              if (rawValue != null) {
                // Convert water_level: 0 = มีน้ำ, 1 = ไม่มีน้ำ
                dynamic displayValue = rawValue;
                String displayUnit = sensorConfig.unit;
                if (sensorConfig.key == 'water_level') {
                  displayValue = rawValue == 0 ? 'มีน้ำ' : 'ไม่มีน้ำ';
                  displayUnit = '';
                }
                cards.add(
                  SensorCard(
                    title: sensorConfig.title,
                    value: displayValue,
                    unit: displayUnit,
                    icon: IconHelper.getIcon(sensorConfig.icon),
                    color: IconHelper.getColor(sensorConfig.color),
                  ),
                );
              }
            }

            // Add device cards
            for (var deviceConfig in sortedDevices) {
              final isOn = _getDeviceState(data.devices, deviceConfig.key);
              if (isOn != null) {
                cards.add(
                  DeviceCard(
                    title: deviceConfig.title,
                    isOn: isOn,
                    icon: IconHelper.getIcon(deviceConfig.icon),
                    enabled: deviceConfig.enabled,
                    mode: deviceConfig.controlMode,
                    onToggle: (value) async {
                      await _realtimeService.updateDeviceControl(
                        farmId,
                        deviceConfig.key,
                        value,
                      );
                    },
                  ),
                );
              }
            }

            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: cards,
            );
          },
        );
      },
    );
  }

  double? _getSensorValue(SensorReadings sensors, String key) {
    switch (key) {
      case 'tds':
        return sensors.tds;
      case 'temperature':
        return sensors.temperature;
      case 'light':
        return sensors.light;
      case 'water_level':
        return sensors.waterLevel;
      case 'humidity':
        return sensors.humidity;
      default:
        return null;
    }
  }

  bool? _getDeviceState(DeviceControls devices, String key) {
    switch (key) {
      case 'led':
        return devices.led;
      case 'water_pump':
        return devices.waterPump;
      default:
        return null;
    }
  }
}
