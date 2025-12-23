import 'package:flutter/material.dart';
import '../../../data/models/device_model.dart';

class DeviceSelector extends StatelessWidget {
  final List<DeviceModel> devices;
  final String? selectedDeviceId;
  final ValueChanged<String> onDeviceChanged;
  final VoidCallback? onAddDevice;
  final double? width;

  const DeviceSelector({
    super.key,
    required this.devices,
    this.selectedDeviceId,
    required this.onDeviceChanged,
    this.onAddDevice,
    this.width,
  });

  String get selectedDeviceName {
    if (selectedDeviceId == null || devices.isEmpty) return 'ไม่มีอุปกรณ์';
    try {
      return devices.firstWhere((d) => d.deviceId == selectedDeviceId).deviceName;
    } catch (e) {
      return 'ไม่มีอุปกรณ์';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectorWidth = width ?? MediaQuery.of(context).size.width - 32;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: PopupMenuButton<String>(
              offset: const Offset(0, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: BoxConstraints(
                minWidth: selectorWidth - 70,
                maxWidth: selectorWidth - 70,
              ),
              enabled: devices.isNotEmpty,
              onSelected: onDeviceChanged,
              itemBuilder: (context) => devices.isEmpty
                  ? [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text(
                          'ไม่มีอุปกรณ์',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ]
                  : devices
                      .map(
                        (device) => PopupMenuItem(
                          value: device.deviceId,
                          child: Row(
                            children: [
                              Icon(
                                Icons.sensors,
                                color: selectedDeviceId == device.deviceId
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      device.deviceName,
                                      style: TextStyle(
                                        fontWeight: selectedDeviceId == device.deviceId
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: selectedDeviceId == device.deviceId
                                            ? Theme.of(context).primaryColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      device.deviceId,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      devices.isEmpty ? Icons.sensors_off : Icons.sensors,
                      color: devices.isEmpty ? Colors.grey : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedDeviceName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: devices.isEmpty ? Colors.grey : null,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: devices.isEmpty ? Colors.grey : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onAddDevice != null) ...[
            const SizedBox(width: 12),
            Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              child: InkWell(
                onTap: onAddDevice,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
