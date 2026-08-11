import 'package:agrisense/core/services/board_service.dart';
import 'package:agrisense/data/models/board_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/selector.dart';

class CameraConfigPage extends StatefulWidget {
  const CameraConfigPage({super.key});

  @override
  State<CameraConfigPage> createState() => _CameraConfigPageState();
}

class _CameraConfigPageState extends State<CameraConfigPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่ากล้อง'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _boards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
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
                      Expanded(child: _buildCameraConfig()),
                  ],
                ),
    );
  }

  Widget _buildCameraConfig() {
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
        final camera = data?['camera'] as Map<String, dynamic>?;

        if (camera == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่พบการตั้งค่ากล้อง'),
              ],
            ),
          );
        }

        final enabled = camera['enabled'] as bool? ?? false;
        final deviceIndex = camera['device_index'] as num? ?? 0;
        final resolution =
            camera['resolution'] as Map<String, dynamic>? ?? {};
        final width = resolution['width'] as num? ?? 1280;
        final height = resolution['height'] as num? ?? 720;
        final saveLocal = camera['save_local'] as bool? ?? true;
        final localPath = camera['local_path'] as String? ?? '';
        final apiUrl = camera['plant_disease_api'] as String? ?? '';
        final schedule = camera['schedule'] as List<dynamic>? ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      enabled ? Icons.videocam : Icons.videocam_off,
                      size: 40,
                      color: enabled ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            enabled ? 'กล้องเปิดอยู่' : 'กล้องปิดอยู่',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: enabled
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'Device Index: $deviceIndex',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: enabled,
                      onChanged: (val) =>
                          _updateCameraField('enabled', val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Resolution Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    const Icon(Icons.aspect_ratio, color: Colors.blue),
                title: const Text('ความละเอียด'),
                subtitle: Text('${width}x$height'),
              ),
            ),
            const SizedBox(height: 12),

            // Storage Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary:
                        const Icon(Icons.save, color: Colors.orange),
                    title: const Text('บันทึกภาพในเครื่อง'),
                    subtitle:
                        saveLocal ? Text('พาธ: $localPath') : null,
                    value: saveLocal,
                    onChanged: (val) =>
                        _updateCameraField('save_local', val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // API Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  Icons.cloud,
                  color: apiUrl.isNotEmpty ? Colors.green : Colors.grey,
                ),
                title: const Text('Plant Disease API'),
                subtitle: Text(
                  apiUrl.isNotEmpty ? apiUrl : 'ยังไม่ได้ตั้งค่า',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        apiUrl.isNotEmpty ? null : Colors.red.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editApiUrl(apiUrl),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Section
            Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ตารางเวลาถ่ายภาพ',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Colors.green),
                  onPressed: () => _addScheduleTime(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (schedule.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'ยังไม่มีตารางเวลา\nกด + เพื่อเพิ่ม',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...List.generate(schedule.length, (index) {
                final item =
                    schedule[index] as Map<String, dynamic>? ?? {};
                final time = item['time'] as String? ?? '--:--';
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.access_time,
                        color: Colors.deepPurple),
                    title: Text(
                      time,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 20, color: Colors.blue),
                          onPressed: () =>
                              _editScheduleTime(index, time),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20, color: Colors.red),
                          onPressed: () =>
                              _deleteScheduleTime(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Future<void> _updateCameraField(String field, dynamic value) async {
    try {
      await _firestore
          .collection('device_configs')
          .doc(_selectedBoardId)
          .update({
        'camera.$field': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _editApiUrl(String currentUrl) async {
    final controller = TextEditingController(text: currentUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไข API URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      await _updateCameraField('plant_disease_api', result);
    }
  }

  Future<void> _addScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('device_configs')
        .doc(_selectedBoardId)
        .get();
    final data = doc.data();
    final camera = data?['camera'] as Map<String, dynamic>? ?? {};
    final schedule = List<Map<String, dynamic>>.from(
      (camera['schedule'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );
    schedule.add({'time': timeStr});
    schedule.sort(
        (a, b) => (a['time'] as String).compareTo(b['time'] as String));

    await _updateCameraField('schedule', schedule);
  }

  Future<void> _editScheduleTime(int index, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute:
          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) return;

    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('device_configs')
        .doc(_selectedBoardId)
        .get();
    final data = doc.data();
    final camera = data?['camera'] as Map<String, dynamic>? ?? {};
    final schedule = List<Map<String, dynamic>>.from(
      (camera['schedule'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );
    if (index < schedule.length) {
      schedule[index] = {'time': timeStr};
      schedule.sort(
          (a, b) => (a['time'] as String).compareTo(b['time'] as String));
      await _updateCameraField('schedule', schedule);
    }
  }

  Future<void> _deleteScheduleTime(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบตารางเวลา'),
        content: const Text('ต้องการลบเวลานี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final doc = await _firestore
        .collection('device_configs')
        .doc(_selectedBoardId)
        .get();
    final data = doc.data();
    final camera = data?['camera'] as Map<String, dynamic>? ?? {};
    final schedule = List<Map<String, dynamic>>.from(
      (camera['schedule'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );
    if (index < schedule.length) {
      schedule.removeAt(index);
      await _updateCameraField('schedule', schedule);
    }
  }
}
