import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static DeviceInfo? _instance;

  final String deviceId;

  DeviceInfo._({required this.deviceId});

  static Future<void> initialize() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.androidId == null) {
      throw Exception('Could not load DeviceInfo because androidId is null');
    }
    final deviceId = androidInfo.androidId!;
    _instance ??= DeviceInfo._(deviceId: deviceId);
  }

  static DeviceInfo get instance {
    if (_instance == null) {
      throw Exception(
          'DeviceInfo.instance was accessed before calling DeviceInfo.initialize');
    }
    return _instance!;
  }
}
