class DeviceModel {
  final String deviceId;
  final String deviceName;
  final DateTime createdAt;

  DeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
