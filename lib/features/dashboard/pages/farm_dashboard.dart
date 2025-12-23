import 'package:agrisense/core/services/realtime_database_service.dart';
import 'package:agrisense/data/models/sensor_data_model.dart';
import 'package:agrisense/features/dashboard/pages/device_card.dart';
import 'package:agrisense/features/dashboard/pages/sensor_card.dart';
import 'package:flutter/material.dart';

class FarmDashboard extends StatelessWidget {
  final String farmId;
  final RealtimeDatabaseService _realtimeService = RealtimeDatabaseService();

  FarmDashboard({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
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

        return GridView(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          children: [
            SensorCard(
              title: "ค่า pH",
              value: data.sensors.ph,
              unit: "",
              icon: Icons.science,
              color: Colors.purple,
            ),
            SensorCard(
              title: "อุณหภูมิ",
              value: data.sensors.temperature,
              unit: "°C",
              icon: Icons.thermostat,
              color: Colors.orange,
            ),
            SensorCard(
              title: "แสง",
              value: data.sensors.light,
              unit: "lux",
              icon: Icons.wb_sunny,
              color: Colors.amber,
            ),
            SensorCard(
              title: "ระดับน้ำ",
              value: data.sensors.waterLevel,
              unit: "%",
              icon: Icons.water,
              color: Colors.blue,
            ),
            DeviceCard(
              title: "LED",
              isOn: data.devices.led,
              icon: Icons.lightbulb,
              onToggle: (value) async {
                await _realtimeService.updateLED(farmId, value);
              },
            ),
            DeviceCard(
              title: "ปั๊มน้ำ",
              isOn: data.devices.waterPump,
              icon: Icons.waterfall_chart,
              onToggle: (value) async {
                await _realtimeService.updateWaterPump(farmId, value);
              },
            ),
          ],
        );
      },
    );
  }
}
