import 'package:flutter/material.dart';
import '../../../core/widgets/mobile_navigation.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileNavigationScaffold(
      currentIndex: 0,
      body: Center(
        child: Text(
          'ยินดีต้อนรับสู่แดชบอร์ด',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
