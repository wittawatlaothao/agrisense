import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/repositories/prediction_history_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isUploading = false;
  bool _isFlashOn = false;
  String? _result;
  final PredictionHistoryService _historyService = PredictionHistoryService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause/resume camera when app lifecycle changes
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController(cameraController.description);
    }
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _initController(_cameras!.first);
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  Future<void> _initController(CameraDescription description) async {
    _controller?.dispose();
    final controller = CameraController(description, ResolutionPreset.medium,
        enableAudio: false);
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // handle
    }
  }

  Future<void> _takePictureAndUpload() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      await _uploadFile(File(file.path));
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pickImageAndUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    await _uploadFile(File(picked.path));
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isUploading = true;
      _result = null;
    });
    final uri = Uri.parse('https://agrisense-ai-dev.up.railway.app/predict');
    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        file.path,
        contentType: http.MediaType('image', 'jpeg'),
      ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        setState(() {
          _result = body;
        });
        
        try {
          final data = jsonDecode(body);
          final predictions = data["predictions"] as List?;
          
          if (predictions == null || predictions.isEmpty) {
            _showError('ไม่พบผลการวิเคราะห์');
            return;
          }
          
          final firstPrediction = predictions.first as Map<String, dynamic>;
          final prediction = firstPrediction["prediction"] as Map<String, dynamic>?;
          
          if (prediction == null) {
            _showError('ไม่พบข้อมูล prediction');
            return;
          }
          
          final label = prediction["label"] as String?;
          final confidence = prediction["confidence"] as num?;
          
          if (label == null || confidence == null) {
            _showError('ข้อมูล prediction ไม่สมบูรณ์');
            return;
          }
          
          final probabilities = (prediction["probabilities"] as Map<String, dynamic>?) ?? {};
          
          // Upload รูปไป Firebase Storage
          String? imageUrl;
          try {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('predictions')
                .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
            await storageRef.putFile(file);
            imageUrl = await storageRef.getDownloadURL();
          } catch (e) {
            print('Failed to upload image: $e');
          }
          
          // บันทึกประวัติการ predict พร้อม imageUrl และ probabilities
          try {
            await _historyService.savePrediction(
              label: label,
              confidence: confidence.toDouble(),
              imageUrl: imageUrl,
              probabilities: probabilities.isNotEmpty ? probabilities : null,
            );
          } catch (e) {
            print('Failed to save history: $e');
          }
          
          if (!mounted) return;
          
          Navigator.pushReplacementNamed(
            context,
            "/predict_result",
            arguments: {
              "image": file,
              "label": label,
              "confidence": confidence.toDouble(),
              "probabilities": probabilities,
            },
          );
        } catch (e) {
          _showError('Error parsing response: $e');
        }
        } else {
        _showError('Server error: ${response.statusCode}\n$body');
      }
    } catch (e) {
      _showError('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กล้อง'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            tooltip: _isFlashOn ? 'ปิดแฟลช' : 'เปิดแฟลช',
            onPressed: () async {
              if (_controller == null || !_controller!.value.isInitialized) return;
              try {
                final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
                await _controller!.setFlashMode(newMode);
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              } catch (e) {
                // Flash not supported
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'ประวัติการตรวจสอบ',
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isInitialized && _controller != null
                  ? CameraPreview(_controller!)
                  : const Text('ไม่พบกล้องหรือกำลังโหลด...'),
            ),
          ),
            Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
              const SizedBox(height: 16),
              Row(
                children: [
                // Left aligned
                Expanded(
                  child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickImageAndUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('อัปโหลด'),
                  ),
                  ),
                ),

                // Centered
                Expanded(
                  child: Center(
                  child: FloatingActionButton(
                    onPressed: _isUploading ? null : _takePictureAndUpload,
                    child: const Icon(Icons.camera_alt),
                  ),
                  ),
                ),

                // Right aligned
                Expanded(
                  child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading
                      ? null
                      : () async {
                        // switch camera
                        if (_cameras == null || _cameras!.length < 2) return;
                        final current = _controller!.description;
                        final index = _cameras!.indexWhere((c) => c.name == current.name);
                        final next = _cameras![(index + 1) % _cameras!.length];
                        await _initController(next);
                      },
                    icon: const Icon(Icons.flip_camera_android),
                    label: const Text('สลับ'),
                  ),
                  ),
                ),
                ],
              ),
              ...[const SizedBox(height: 3),
              Text(''),],
              if (_isUploading) const LinearProgressIndicator(),
              ...[const SizedBox(height: 3),
              Text(''),],
              ],
            ),
            )
        ],
      ),
    );
  }
}