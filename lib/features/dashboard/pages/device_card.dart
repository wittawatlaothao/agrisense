import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final bool isOn;
  final IconData icon;
  final ValueChanged<bool>? onToggle;
  final bool enabled;
  final String? mode;

  const DeviceCard({
    super.key,
    required this.title,
    required this.isOn,
    required this.icon,
    this.onToggle,
    this.enabled = true,
    this.mode,
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
          if (mode != null && mode != 'manual')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'โหมด: ${_getModeText(mode!)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          Switch(
            value: isOn,
            activeColor: Colors.green,
            onChanged: enabled && mode == 'manual' ? onToggle : null,
          )
        ],
      ),
    );
  }

  String _getModeText(String mode) {
    switch (mode) {
      case 'manual':
        return 'ควบคุมเอง';
      case 'condition':
        return 'เงื่อนไข';
      case 'schedule':
        return 'ตามเวลา';
      case 'auto':
        return 'อัตโนมัติ';
      default:
        return mode;
    }
  }
}
