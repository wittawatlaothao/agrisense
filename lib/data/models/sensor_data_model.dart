class SensorDataModel {
  final String deviceId;
  final DeviceControls devices;
  final String? lastUpdate;
  final SensorReadings sensors;
  final String status;
  final String? timestamp;

  SensorDataModel({
    required this.deviceId,
    required this.devices,
    this.lastUpdate,
    required this.sensors,
    required this.status,
    this.timestamp,
  });

  factory SensorDataModel.fromMap(Map<dynamic, dynamic> map) {
    return SensorDataModel(
      deviceId: map['deviceId']?.toString() ?? '',
      devices: DeviceControls.fromMap(
          map['devices'] as Map<dynamic, dynamic>? ?? {}),
      lastUpdate: map['lastUpdate']?.toString(),
      sensors: SensorReadings.fromMap(
          map['sensors'] as Map<dynamic, dynamic>? ?? {}),
      status: map['status']?.toString() ?? 'offline',
      timestamp: map['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'devices': devices.toMap(),
      'lastUpdate': lastUpdate,
      'sensors': sensors.toMap(),
      'status': status,
      'timestamp': timestamp,
    };
  }
}

class DeviceControls {
  final bool led;
  final bool waterPump;

  DeviceControls({
    required this.led,
    required this.waterPump,
  });

  factory DeviceControls.fromMap(Map<dynamic, dynamic> map) {
    return DeviceControls(
      led: map['led'] == true,
      waterPump: map['water_pump'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'led': led,
      'water_pump': waterPump,
    };
  }
}

class SensorReadings {
  final double light;
  final double ph;
  final double temperature;
  final double waterLevel;

  SensorReadings({
    required this.light,
    required this.ph,
    required this.temperature,
    required this.waterLevel,
  });

  factory SensorReadings.fromMap(Map<dynamic, dynamic> map) {
    return SensorReadings(
      light: (map['light'] ?? 0).toDouble(),
      ph: (map['ph'] ?? 0).toDouble(),
      temperature: (map['temperature'] ?? 0).toDouble(),
      waterLevel: (map['water_level'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'light': light,
      'ph': ph,
      'temperature': temperature,
      'water_level': waterLevel,
    };
  }
}
