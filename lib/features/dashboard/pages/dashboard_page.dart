import 'package:agrisense/features/dashboard/pages/farm_dashboard.dart';
import 'package:agrisense/features/dashboard/pages/qr_scanner_page.dart';
import 'package:agrisense/features/dashboard/pages/add_device_page.dart';
import 'package:agrisense/features/dashboard/widgets/selector.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final farms = const [
    {"id": "farm1", "name": "Farm A"},
    {"id": "farm2", "name": "Farm B"},
  ];

  late String selectedFarmId;

  @override
  void initState() {
    super.initState();
    selectedFarmId = farms.first["id"]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          // 🔽 Farm Selector
          FarmSelector(
            farms: farms,
            selectedFarmId: selectedFarmId,
            onFarmChanged: (value) {
              setState(() {
                selectedFarmId = value;
              });
            },
            onAddFarm: () async {
              // เปิดหน้าสแกน QR code
              final scannedDeviceId = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerPage(),
                ),
              );

              if (scannedDeviceId != null && mounted) {
                // เปิดหน้าฟอร์มเพิ่ม device
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDevicePage(
                      scannedDeviceId: scannedDeviceId,
                    ),
                  ),
                );

                // ถ้าบันทึกสำเร็จ อาจจะ refresh ข้อมูล
                if (result == true && mounted) {
                  // TODO: Refresh device list if needed
                  setState(() {});
                }
              }
            },
          ),

          // 📊 Dashboard Content
          Expanded(
            child: FarmDashboard(farmId: selectedFarmId),
          ),
        ],
      ),
    );
  }
}
