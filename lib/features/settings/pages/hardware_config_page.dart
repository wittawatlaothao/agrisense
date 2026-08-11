import 'package:agrisense/core/services/board_service.dart';
import 'package:agrisense/data/models/board_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/selector.dart';
import 'edit_device_config_page.dart';

class HardwareConfigPage extends StatefulWidget {
  const HardwareConfigPage({super.key});

  @override
  State<HardwareConfigPage> createState() => _HardwareConfigPageState();
}

class _HardwareConfigPageState extends State<HardwareConfigPage> {
  final BoardService _boardService = BoardService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedBoardId;
  List<BoardModel> _boards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    setState(() => _isLoading = true);
    try {
      final boards = await _boardService.getUserBoards();
      setState(() {
        _boards = boards;
        if (boards.isNotEmpty) {
          _selectedBoardId = boards.first.boardId;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _editHardwareConfig(String type, String key, Map<String, dynamic> configData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDeviceConfigPage(
          boardId: _selectedBoardId!,
          type: type,
          configKey: key,
          configData: configData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าอุปกรณ์และเซ็นเซอร์'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _boards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('ไม่พบบอร์ด'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadBoards,
                        child: const Text('โหลดใหม่'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    BoardSelector(
                      boards: _boards,
                      selectedBoardId: _selectedBoardId,
                      onBoardChanged: (boardId) {
                        setState(() {
                          _selectedBoardId = boardId;
                        });
                      },
                    ),
                    if (_selectedBoardId != null)
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              const TabBar(
                                tabs: [
                                  Tab(text: 'เซ็นเซอร์', icon: Icon(Icons.sensors)),
                                  Tab(text: 'อุปกรณ์', icon: Icon(Icons.devices)),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildHardwareSensorsList(),
                                    _buildHardwareDevicesList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildHardwareSensorsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('device_configs')
          .doc(_selectedBoardId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final sensors = data?['sensors'] as Map<String, dynamic>? ?? {};

        if (sensors.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่พบเซ็นเซอร์'),
              ],
            ),
          );
        }

        final sensorList = sensors.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sensorList.length,
          itemBuilder: (context, index) {
            final entry = sensorList[index];
            final sensorKey = entry.key;
            final sensorData = entry.value as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.sensors,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(sensorKey),
                subtitle: Text(
                  'Type: ${sensorData['sensor_type'] ?? 'N/A'} | Fields: ${sensorData.keys.length}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editHardwareConfig('sensor', sensorKey, sensorData),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHardwareDevicesList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('device_configs')
          .doc(_selectedBoardId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final devices = data?['devices'] as Map<String, dynamic>? ?? {};

        if (devices.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.devices_other, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่พบอุปกรณ์'),
              ],
            ),
          );
        }

        final deviceList = devices.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deviceList.length,
          itemBuilder: (context, index) {
            final entry = deviceList[index];
            final deviceKey = entry.key;
            final deviceData = entry.value as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.power,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(deviceKey),
                subtitle: Text(
                  'Type: ${deviceData['type'] ?? 'N/A'} | Pin: ${deviceData['pin'] ?? 'N/A'} | Enabled: ${deviceData['enabled'] ?? false}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editHardwareConfig('device', deviceKey, deviceData),
              ),
            );
          },
        );
      },
    );
  }
}
