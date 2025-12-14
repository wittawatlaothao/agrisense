import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  String? _result;

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
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        setState(() {
          _result = body;
        });
        Navigator.pushReplacementNamed(context, "/home");
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
      appBar: AppBar(title: const Text('Camera')),
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
              ...[const SizedBox(height: 8),
              Text(''),],
              if (_isUploading) const LinearProgressIndicator(),
              if (_result != null) ...[
                const SizedBox(height: 8),
                Text('ผลลัพธ์: $_result'),
              ],
              ],
            ),
            )
        ],
      ),
    );
  }
}