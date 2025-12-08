import 'package:flutter/material.dart';
import '../../../core/widgets/mobile_navigation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileNavigationScaffold(
      currentIndex: 2,
      body: Center(
        child: Text('หน้าโปรไฟล์ (ตัวอย่าง)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
