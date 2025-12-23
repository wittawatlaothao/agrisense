import 'package:agrisense/features/dashboard/pages/farm_dashboard.dart';
import 'package:agrisense/features/dashboard/pages/qr_scanner_page.dart';
import 'package:agrisense/features/dashboard/pages/add_device_page.dart';
import 'package:agrisense/features/dashboard/widgets/selector.dart';
import 'package:agrisense/core/services/device_service.dart';
import 'package:agrisense/data/models/device_model.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _deviceService = DeviceService();
  List<DeviceModel> devices = [];
  String? selectedDeviceId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedDevices = await _deviceService.getUserDevices();
      setState(() {
        devices = loadedDevices;
        if (devices.isNotEmpty && selectedDeviceId == null) {
          selectedDeviceId = devices.first.deviceId;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔽 Device Selector
                DeviceSelector(
                  devices: devices,
                  selectedDeviceId: selectedDeviceId,
                  onDeviceChanged: (value) {
                    setState(() {
                      selectedDeviceId = value;
                    });
                  },
                  onAddDevice: () async {
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

                      // ถ้าบันทึกสำเร็จ refresh device list
                      if (result == true && mounted) {
                        await _loadDevices();
                      }
                    }
                  },
                ),

                // 📊 Dashboard Content
                Expanded(
                  child: selectedDeviceId != null
                      ? FarmDashboard(farmId: selectedDeviceId!)
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sensors_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'ไม่มีอุปกรณ์',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'กดปุ่ม + เพื่อเพิ่มอุปกรณ์',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
