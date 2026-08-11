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

    final File? imageFile = args["image"];
    final String? imageUrl = args["imageUrl"];
    final String label = args["label"];
    final double confidence = args["confidence"];
    final Map<String, dynamic>? probabilities = args["probabilities"] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ผลการตรวจสอบ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.white,
                child: imageFile != null
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.contain,
                      )
                    : imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error_outline, size: 64),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Icons.image_not_supported, size: 64),
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

            // Probabilities
            if (probabilities != null && probabilities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.pie_chart, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'ความน่าจะเป็นของแต่ละประเภท',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...probabilities.entries.map((entry) {
                        final className = entry.key;
                        final probability = (entry.value as num).toDouble();
                        final percentage = probability * 100;
                        final color = probability >= 0.7
                            ? Colors.green
                            : probability >= 0.5
                                ? Colors.orange
                                : Colors.red;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    className,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: probability,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

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
