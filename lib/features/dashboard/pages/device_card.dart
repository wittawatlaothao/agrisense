import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final bool isOn;
  final IconData icon;
  final ValueChanged<bool> onToggle;

  const DeviceCard({
    super.key,
    required this.title,
    required this.isOn,
    required this.icon,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOn ? Colors.green : Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Switch(
            value: isOn,
            activeColor: Colors.green,
            onChanged: onToggle,
          )
        ],
      ),
    );
  }
}
