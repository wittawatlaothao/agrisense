class DashboardConfigModel {
  final List<SensorConfig> sensors;
  final List<DeviceConfig> devices;

  DashboardConfigModel({
    required this.sensors,
    required this.devices,
  });

  factory DashboardConfigModel.fromMap(Map<dynamic, dynamic> map) {
    final sensorsMap = map['sensors'] as Map<dynamic, dynamic>? ?? {};
    final devicesMap = map['devices'] as Map<dynamic, dynamic>? ?? {};

    return DashboardConfigModel(
      sensors: sensorsMap.entries
          .map((e) => SensorConfig.fromMap(e.key.toString(), e.value))
          .toList(),
      devices: devicesMap.entries
          .map((e) => DeviceConfig.fromMap(e.key.toString(), e.value))
          .toList(),
    );
  }

  // Default configuration ถ้าไม่มีใน database
  factory DashboardConfigModel.defaultConfig() {
    return DashboardConfigModel(
      sensors: [
        SensorConfig(
          key: 'ph',
          title: 'ค่า pH',
          unit: '',
          icon: 'science',
          color: 'purple',
          order: 0,
        ),
        SensorConfig(
          key: 'temperature',
          title: 'อุณหภูมิ',
          unit: '°C',
          icon: 'thermostat',
          color: 'orange',
          order: 1,
        ),
        SensorConfig(
          key: 'light',
          title: 'แสง',
          unit: 'lux',
          icon: 'wb_sunny',
          color: 'amber',
          order: 2,
        ),
        SensorConfig(
          key: 'water_level',
          title: 'ระดับน้ำ',
          unit: '%',
          icon: 'water',
          color: 'blue',
          order: 3,
        ),
        SensorConfig(
          key: 'humidity',
          title: 'ความชื้น',
          unit: '%',
          icon: 'opacity',
          color: 'cyan',
          order: 4,
        ),
      ],
      devices: [
        DeviceConfig(
          key: 'led',
          title: 'LED',
          icon: 'lightbulb',
          color: 'yellow',
          order: 0,
        ),
        DeviceConfig(
          key: 'water_pump',
          title: 'ปั๊มน้ำ',
          icon: 'waterfall_chart',
          color: 'blue',
          order: 1,
        ),
      ],
    );
  }
}

class SensorConfig {
  final String key; // ph, temperature, light, water_level
  final String title;
  final String unit;
  final String icon; // icon name
  final String color; // color name
  final int order;

  SensorConfig({
    required this.key,
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
    required this.order,
  });

  factory SensorConfig.fromMap(String key, dynamic map) {
    if (map is! Map) {
      return SensorConfig(
        key: key,
        title: key,
        unit: '',
        icon: 'sensors',
        color: 'grey',
        order: 0,
      );
    }

    // Parse order safely
    int order = 0;
    final orderValue = map['order'];
    if (orderValue != null) {
      if (orderValue is int) {
        order = orderValue;
      } else if (orderValue is double) {
        order = orderValue.toInt();
      } else {
        order = int.tryParse(orderValue.toString()) ?? 0;
      }
    }

    return SensorConfig(
      key: key,
      title: map['title']?.toString() ?? key,
      unit: map['unit']?.toString() ?? '',
      icon: map['icon']?.toString() ?? 'sensors',
      color: map['color']?.toString() ?? 'grey',
      order: order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'unit': unit,
      'icon': icon,
      'color': color,
      'order': order,
    };
  }
}

class DeviceConfig {
  final String key; // led, water_pump
  final String title;
  final String icon;
  final String color;
  final int order;
  final bool enabled;
  final String controlMode; // manual, condition, schedule, auto

  DeviceConfig({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.order,
    this.enabled = true,
    this.controlMode = 'manual',
  });

  factory DeviceConfig.fromMap(String key, dynamic map) {
    if (map is! Map) {
      return DeviceConfig(
        key: key,
        title: key,
        icon: 'device_unknown',
        color: 'grey',
        order: 0,
      );
    }

    // ดึง control mode จาก control.mode
    String controlMode = 'manual';
    bool enabled = true;
    if (map['control'] != null && map['control'] is Map) {
      final control = map['control'] as Map;
      controlMode = control['mode']?.toString() ?? 'manual';
    }
    
    enabled = map['enabled'] == true;

    // Parse order safely
    int order = 0;
    final orderValue = map['order'];
    if (orderValue != null) {
      if (orderValue is int) {
        order = orderValue;
      } else if (orderValue is double) {
        order = orderValue.toInt();
      } else {
        order = int.tryParse(orderValue.toString()) ?? 0;
      }
    }

    return DeviceConfig(
      key: key,
      title: map['title']?.toString() ?? key,
      icon: map['icon']?.toString() ?? 'device_unknown',
      color: map['color']?.toString() ?? 'grey',
      order: order,
      enabled: enabled,
      controlMode: controlMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
      'color': color,
      'order': order,
      'enabled': enabled,
      'control': {
        'mode': controlMode,
      },
    };
  }
}
