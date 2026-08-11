import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'science':
        return Icons.science;
      case 'thermostat':
        return Icons.thermostat;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'water':
        return Icons.water;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'waterfall_chart':
        return Icons.waterfall_chart;
      case 'sensors':
        return Icons.sensors;
      case 'device_unknown':
        return Icons.device_unknown;
      case 'opacity':
        return Icons.opacity;
      case 'water_drop':
        return Icons.water_drop;
      case 'light_mode':
        return Icons.light_mode;
      case 'wb_incandescent':
        return Icons.wb_incandescent;
      default:
        return Icons.help_outline;
    }
  }

  static Color getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'amber':
        return Colors.amber;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'cyan':
        return Colors.cyan;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
