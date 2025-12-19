import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/device_service.dart';
import '../../../data/models/device_model.dart';

class AddDevicePage extends StatefulWidget {
  final String scannedDeviceId;

  const AddDevicePage({
    super.key,
    required this.scannedDeviceId,
  });

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceService = DeviceService();
  bool _isLoading = false;

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final device = DeviceModel(
        deviceId: widget.scannedDeviceId,
        deviceName: _deviceNameController.text.trim(),
        createdAt: DateTime.now(),
      );

      final success = await _deviceService.addDevice(device);

      if (!mounted) return;

      if (success) {
        Fluttertoast.showToast(
          msg: 'เพิ่มอุปกรณ์สำเร็จ',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(
          msg: 'เกิดข้อผิดพลาด: ไม่สามารถบันทึกข้อมูลได้',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      
      String errorMsg = 'เกิดข้อผิดพลาด Firebase: ';
      if (e.code == 'permission-denied') {
        errorMsg += 'ไม่มีสิทธิ์เข้าถึงข้อมูล';
      } else if (e.code == 'unavailable') {
        errorMsg += 'ไม่สามารถเชื่อมต่อได้';
      } else {
        errorMsg += e.message ?? e.code;
      }
      
      Fluttertoast.showToast(
        msg: errorMsg,
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'เกิดข้อผิดพลาด: ${e.toString()}',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มอุปกรณ์'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Success Message
              const Text(
                'สแกน QR Code สำเร็จ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Device ID Field (Read-only)
              TextFormField(
                initialValue: widget.scannedDeviceId,
                decoration: const InputDecoration(
                  labelText: 'รหัสอุปกรณ์',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Device Name Field
              TextFormField(
                controller: _deviceNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่ออุปกรณ์',
                  hintText: 'เช่น เซ็นเซอร์ในโรงเรือน A',
                  prefixIcon: Icon(Icons.device_hub),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่ออุปกรณ์';
                  }
                  if (value.trim().length < 3) {
                    return 'ชื่ออุปกรณ์ต้องมีอย่างน้อย 3 ตัวอักษร';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDevice,
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
                          'บันทึก',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
