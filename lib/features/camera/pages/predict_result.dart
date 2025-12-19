import 'dart:io';
import 'package:agrisense/core/widgets/mobile_navigation.dart';
import 'package:flutter/material.dart';

class PredictResultPage extends StatelessWidget {
  const PredictResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;
    
    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        body: Center(
          child: Text('ไม่พบข้อมูลผลลัพธ์'),
        ),
      );
    }

    final File imageFile = args["image"];
    final String label = args["label"];
    final double confidence = args["confidence"];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ผลการตรวจสอบ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.white, // พื้นหลัง
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Label
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.eco, color: Colors.green),
                title: const Text(
                  'ผลการวิเคราะห์',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  label,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confidence
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text(
                  'ความมั่นใจ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(confidence * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: confidence,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ปุ่ม
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MobileNavigationScaffold(
                        currentIndex: 1, // Camera
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('ตรวจสอบใหม่'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
