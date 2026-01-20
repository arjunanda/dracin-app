import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  String? _deviceId;

  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id; // Unique ID on Android
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
      } else {
        _deviceId = 'unknown_device';
      }
    } catch (e) {
      // Fallback if plugin fails (e.g. MissingPluginException before rebuild)
      _deviceId = 'temp_device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return _deviceId ?? 'unknown_device';
  }
}
