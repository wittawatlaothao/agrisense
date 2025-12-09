import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('ถ่ายภาพเพื่อส่งไป AI', style: TextStyle(fontSize: 18)),
    );
  }
}