import 'package:agrisense/features/dashboard/pages/farm_dashboard.dart';
import 'package:agrisense/features/dashboard/pages/qr_scanner_page.dart';
import 'package:agrisense/features/dashboard/pages/add_device_page.dart';
import 'package:agrisense/core/widgets/selector.dart';
import 'package:agrisense/core/services/board_service.dart';
import 'package:agrisense/core/services/notification_service.dart';
import 'package:agrisense/data/models/board_model.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _boardService = BoardService();
  List<BoardModel> boards = [];
  String? selectedBoardId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoards();
    _printFCMToken();
  }

  Future<void> _printFCMToken() async {
    final token = await NotificationService().getToken();
    debugPrint('FCM Token: $token');
  }

  Future<void> _loadBoards() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedBoards = await _boardService.getUserBoards();
      setState(() {
        boards = loadedBoards;
        if (boards.isNotEmpty && selectedBoardId == null) {
          selectedBoardId = boards.first.boardId;
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
        title: const Text('แดชบอร์ด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoards,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔽 Board Selector
                BoardSelector(
                  boards: boards,
                  selectedBoardId: selectedBoardId,
                  onBoardChanged: (value) {
                    setState(() {
                      selectedBoardId = value;
                    });
                  },
                  onAddBoard: () async {
                    // เปิดหน้าสแกน QR code
                    final scannedBoardId = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QRScannerPage(),
                      ),
                    );

                    if (scannedBoardId != null && mounted) {
                      // เปิดหน้าฟอร์มเพิ่ม board
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBoardPage(
                            scannedBoardId: scannedBoardId,
                          ),
                        ),
                      );

                      // ถ้าบันทึกสำเร็จ refresh board list
                      if (result == true && mounted) {
                        await _loadBoards();
                      }
                    }
                  },
                ),

                // 📊 Dashboard Content
                Expanded(
                  child: selectedBoardId != null
                      ? FarmDashboard(farmId: selectedBoardId!)
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
