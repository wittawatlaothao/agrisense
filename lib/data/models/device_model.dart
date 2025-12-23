class DeviceModel {
  final String deviceId;
  final String deviceName;
  final String? userId; // เพิ่ม userId สำหรับ top-level collection
  final DateTime createdAt;

  DeviceModel({
    required this.deviceId,
    required this.deviceName,
    this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      if (userId != null) 'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
