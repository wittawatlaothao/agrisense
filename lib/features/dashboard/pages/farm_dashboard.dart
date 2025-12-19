import 'package:agrisense/features/dashboard/pages/device_card.dart';
import 'package:agrisense/features/dashboard/pages/sensor_card.dart';
import 'package:flutter/material.dart';

class FarmDashboard extends StatelessWidget {
  final String farmId;

  const FarmDashboard({super.key, required this.farmId});

  Stream<Map<String, dynamic>> fakeFarmStream(String farmId) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));

      yield {
        "ph": (6 + (farmId.hashCode % 2)) + (0.1 * (DateTime.now().second % 5)),
        "temperature": 25 + (DateTime.now().second % 5),
        "light": 800 + (DateTime.now().second * 5),
        "water": 60 + (DateTime.now().second % 10),
        "led": DateTime.now().second % 2 == 0,
        "pump": DateTime.now().second % 3 == 0,
        "fog": DateTime.now().second % 4 == 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: fakeFarmStream(farmId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

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
              value: data["ph"],
              unit: "",
              icon: Icons.science,
              color: Colors.purple,
            ),
            SensorCard(
              title: "อุณหภูมิ",
              value: data["temperature"],
              unit: "°C",
              icon: Icons.thermostat,
              color: Colors.orange,
            ),
            SensorCard(
              title: "แสง",
              value: data["light"],
              unit: "lux",
              icon: Icons.wb_sunny,
              color: Colors.amber,
            ),
            SensorCard(
              title: "ระดับน้ำ",
              value: data["water"],
              unit: "%",
              icon: Icons.water,
              color: Colors.blue,
            ),
            DeviceCard(
              title: "LED",
              isOn: data["led"],
              icon: Icons.lightbulb,
              onToggle: (v) {},
            ),
            DeviceCard(
              title: "ปั๊มน้ำ",
              isOn: data["pump"],
              icon: Icons.waterfall_chart,
              onToggle: (v) {},
            ),
          ],
        );
      },
    );
  }

}
