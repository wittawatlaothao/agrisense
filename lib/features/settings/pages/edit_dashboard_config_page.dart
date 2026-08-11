import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDashboardConfigPage extends StatefulWidget {
  final String collectionType; // 'sensors' or 'devices'
  final String docId;
  final Map<String, dynamic> configData;

  const EditDashboardConfigPage({
    super.key,
    required this.collectionType,
    required this.docId,
    required this.configData,
  });

  @override
  State<EditDashboardConfigPage> createState() => _EditDashboardConfigPageState();
}

class _EditDashboardConfigPageState extends State<EditDashboardConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late TextEditingController _titleController;
  late TextEditingController _unitController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;
  late TextEditingController _orderController;
  
  bool _isLoading = false;
  bool _isSensor = false;

  @override
  void initState() {
    super.initState();
    _isSensor = widget.collectionType == 'sensors';
    _titleController = TextEditingController(text: widget.configData['title'] ?? '');
    _unitController = TextEditingController(text: widget.configData['unit'] ?? '');
    _iconController = TextEditingController(text: widget.configData['icon'] ?? '');
    _colorController = TextEditingController(text: widget.configData['color'] ?? '');
    _orderController = TextEditingController(text: widget.configData['order']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updates = {
        'title': _titleController.text.trim(),
        'icon': _iconController.text.trim(),
        'color': _colorController.text.trim(),
        'order': int.tryParse(_orderController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isSensor) {
        updates['unit'] = _unitController.text.trim();
      }

      await _firestore
          .collection(widget.collectionType)
          .doc(widget.docId)
          .update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกสำเร็จ')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข Dashboard ${_isSensor ? 'Sensor' : 'Device'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลการแสดงผล',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อที่แสดง',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกชื่อ';
                        }
                        return null;
                      },
                    ),
                    if (_isSensor) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'หน่วย',
                          hintText: 'เช่น °C, %, lux',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รูปแบบการแสดงผล',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _iconController,
                      decoration: const InputDecoration(
                        labelText: 'Icon',
                        hintText: 'เช่น thermostat, lightbulb, water_drop',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'สี',
                        hintText: 'เช่น red, blue, green, orange',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(
                        labelText: 'ลำดับการแสดงผล',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null) {
                            return 'กรุณากรอกตัวเลข';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลที่ไม่สามารถแก้ไขได้',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField(
                      _isSensor ? 'Sensor Type' : 'Device Type',
                      widget.configData[_isSensor ? 'sensorType' : 'deviceType'] ?? '-',
                    ),
                    _buildReadOnlyField('Board ID', widget.configData['boardId'] ?? '-'),
                    if (widget.configData['name'] != null)
                      _buildReadOnlyField('Name', widget.configData['name']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'บันทึกการเปลี่ยนแปลง',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
