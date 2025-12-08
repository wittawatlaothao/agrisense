import 'package:flutter/material.dart';

class MobileNavigationScaffold extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final bool showAppBar;

  const MobileNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    this.showAppBar = false,
  });

  static const List<_NavItem> items = [
    _NavItem(label: 'Dashboard', icon: Icons.dashboard, route: '/dashboard'),
    _NavItem(label: 'Camera', icon: Icons.camera_alt, route: '/camera'),
    _NavItem(label: 'Profile', icon: Icons.person, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(items[currentIndex].label)) : null,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute == '/camera') return;
          Navigator.pushReplacementNamed(context, '/camera');
        },
        child: const Icon(Icons.camera_alt),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: LayoutBuilder(builder: (context, constraints) {
            // Build left and right sides and leave center space for FAB
            final visible = items.where((i) => i.route != '/camera').toList();
            Widget buildItem(_NavItem item) {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              final isActive = currentRoute == item.route;
              final color = isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600];
              return InkWell(
                onTap: () {
                  final currentRoute = ModalRoute.of(context)?.settings.name;
                  if (currentRoute == item.route) return;
                  Navigator.pushReplacementNamed(context, item.route);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: color),
                    const SizedBox(height: 4),
                    Text(item.label, style: TextStyle(color: color, fontSize: 12)),
                  ],
                ),
              );
            }

            // When there are two visible items (common case), put one on each side
            if (visible.length == 2) {
              final left = visible[0];
              final right = visible[1];
              // reserve center width for FAB
              final centerWidth = 80.0;
              final sideWidth = (constraints.maxWidth - centerWidth) / 2;
              return Row(
                children: [
                  SizedBox(width: sideWidth, child: Center(child: buildItem(left))),
                  SizedBox(width: centerWidth),
                  SizedBox(width: sideWidth, child: Center(child: buildItem(right))),
                ],
              );
            }

            // Fallback: spread items evenly
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: visible.map((v) => Expanded(child: Center(child: buildItem(v)))).toList(),
            );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({required this.label, required this.icon, required this.route});
}
