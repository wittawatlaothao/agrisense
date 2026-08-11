import 'package:agrisense/core/services/board_service.dart';
import 'package:agrisense/data/models/board_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/selector.dart';
import 'edit_dashboard_config_page.dart';

class DashboardConfigPage extends StatefulWidget {
  const DashboardConfigPage({super.key});

  @override
  State<DashboardConfigPage> createState() => _DashboardConfigPageState();
}

class _DashboardConfigPageState extends State<DashboardConfigPage> {
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

  Future<void> _editDashboardConfig(String type, String docId, Map<String, dynamic> configData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDashboardConfigPage(
          collectionType: type,
          docId: docId,
          configData: configData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าหน้าแดชบอร์ด'),
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
                                  Tab(text: 'เซ็นเซอร์', icon: Icon(Icons.dashboard)),
                                  Tab(text: 'อุปกรณ์', icon: Icon(Icons.widgets)),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildDashboardSensorsList(),
                                    _buildDashboardDevicesList(),
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

  Widget _buildDashboardSensorsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sensors')
          .where('boardId', isEqualTo: _selectedBoardId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final sensors = snapshot.data?.docs ?? [];

        if (sensors.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่พบ Sensor Config'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sensors.length,
          itemBuilder: (context, index) {
            final sensor = sensors[index];
            final data = sensor.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(data['title'] ?? 'ไม่มีชื่อ'),
                subtitle: Text(
                  'Type: ${data['sensorType']} | Unit: ${data['unit']} | Order: ${data['order']}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editDashboardConfig('sensors', sensor.id, data),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardDevicesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('devices')
          .where('boardId', isEqualTo: _selectedBoardId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final devices = snapshot.data?.docs ?? [];

        if (devices.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.widgets_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่พบ Device Config'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            final data = device.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.widgets,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(data['title'] ?? 'ไม่มีชื่อ'),
                subtitle: Text(
                  'Type: ${data['deviceType']} | Order: ${data['order']}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editDashboardConfig('devices', device.id, data),
              ),
            );
          },
        );
      },
    );
  }
}
