import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDeviceConfigPage extends StatefulWidget {
  final String boardId;
  final String type; // 'sensor' or 'device'
  final String configKey;
  final Map<String, dynamic> configData;

  const EditDeviceConfigPage({
    super.key,
    required this.boardId,
    required this.type,
    required this.configKey,
    required this.configData,
  });

  @override
  State<EditDeviceConfigPage> createState() => _EditDeviceConfigPageState();
}

class _EditDeviceConfigPageState extends State<EditDeviceConfigPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _boolFields = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    widget.configData.forEach((key, value) {
      if (value is bool) {
        _boolFields[key] = value;
      } else if (value is! Map && value is! List) {
        _controllers[key] = TextEditingController(text: value?.toString() ?? '');
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final updates = <String, dynamic>{};
      
      // Update text fields
      _controllers.forEach((key, controller) {
        final value = controller.text.trim();
        // Try to parse as number
        if (int.tryParse(value) != null) {
          updates[key] = int.parse(value);
        } else if (double.tryParse(value) != null) {
          updates[key] = double.parse(value);
        } else {
          updates[key] = value;
        }
      });

      // Update bool fields
      updates.addAll(_boolFields);

      // Preserve nested objects (maps and lists)
      widget.configData.forEach((key, value) {
        if (value is Map || value is List) {
          updates[key] = value;
        }
      });

      final path = widget.type == 'sensor' 
          ? 'sensors.${widget.configKey}' 
          : 'devices.${widget.configKey}';

      await _firestore.collection('device_configs').doc(widget.boardId).update({
        path: updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

  Widget _buildField(String key, dynamic value) {
    if (value is bool) {
      return SwitchListTile(
        title: Text(key),
        value: _boolFields[key] ?? false,
        onChanged: (newValue) {
          setState(() {
            _boolFields[key] = newValue;
          });
        },
      );
    } else if (value is Map) {
      return ExpansionTile(
        title: Text(key),
        subtitle: Text('(map with ${value.length} fields)'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: value.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${e.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value.toString(),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else if (value is List) {
      return ExpansionTile(
        title: Text(key),
        subtitle: Text('(list with ${value.length} items)'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: value.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${e.key}: ${e.value}'),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      // Text field for primitive types
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: key,
            border: const OutlineInputBorder(),
            helperText: 'Type: ${value.runtimeType}',
          ),
          keyboardType: value is num 
              ? TextInputType.number 
              : TextInputType.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type == 'sensor' ? 'Sensor' : 'Device'}: ${widget.configKey}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration Fields',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.configData.entries.map((entry) {
                    return _buildField(entry.key, entry.value);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'หมายเหตุ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ฟิลด์ที่เป็น Map หรือ List จะแสดงเพื่อดูเท่านั้น\n• ต้องแก้ไขข้อมูลซับซ้อนผ่าน Firebase Console',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
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
    );
  }
}
