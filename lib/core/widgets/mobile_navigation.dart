import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/camera/pages/camera_page.dart';
import '../../features/report/pages/report_page.dart';
import '../../features/settings/pages/settings_page.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final Widget page;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.page,
  });
}

class MobileNavigationScaffold extends StatefulWidget {
  final int currentIndex;
  final bool showAppBar;

  const MobileNavigationScaffold({
    super.key,
    this.currentIndex = 0,
    this.showAppBar = false,
  });

  @override
  State<MobileNavigationScaffold> createState() => _MobileNavigationScaffoldState();
}

class _MobileNavigationScaffoldState extends State<MobileNavigationScaffold> {
  late int _activeIndex;

  static const List<_NavItem> items = [
    _NavItem(
      label: 'แดชบอร์ด',
      icon: Icons.dashboard,
      route: '/dashboard',
      page: DashboardPage(),
    ),
    _NavItem(
      label: 'กล้อง',
      icon: Icons.camera_alt,
      route: '/camera',
      page: CameraPage(),
    ),
    _NavItem(
      label: 'แจ้งเตือน',
      icon: Icons.notifications,
      route: '/notifications',
      page: ReportPage(),
    ),
    _NavItem(
      label: 'ตั้งค่า',
      icon: Icons.settings,
      route: '/settings',
      page: SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(items[_activeIndex].label))
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_activeIndex),
          child: items[_activeIndex].page,
        ),
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.dashboard, color: Colors.white),
          Icon(Icons.camera_alt, color: Colors.white),
          Icon(Icons.notifications, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
        ],
        inactiveIcons: const [
          Icon(Icons.dashboard, color: Colors.white),
          Icon(Icons.camera_alt, color: Colors.white),
          Icon(Icons.notifications, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
        ],
        levels: const ["แดชบอร์ด", "กล้อง", "แจ้งเตือน", "ตั้งค่า"],
        activeLevelsStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        inactiveLevelsStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
        color: Colors.white,
        circleColor: Theme.of(context).colorScheme.primary,
        height: 70,
        circleWidth: 60,
        activeIndex: _activeIndex,
        onTap: (index) {
          if (index == _activeIndex) return;
          setState(() {
            _activeIndex = index;
          });
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ],
        ),
      ),
    );
  }
}
