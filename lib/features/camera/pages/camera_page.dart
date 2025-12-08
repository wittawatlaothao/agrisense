import 'package:flutter/material.dart';
import '../../../core/widgets/mobile_navigation.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileNavigationScaffold(
      currentIndex: 1,
      body: Center(
        child: Text('ถ่ายภาพเพื่อส่งไป AI', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}