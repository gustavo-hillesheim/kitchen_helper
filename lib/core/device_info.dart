import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static DeviceInfo? _instance;

  final String deviceId;

  DeviceInfo._({required this.deviceId});

  static Future<void> initialize() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final String deviceId;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else {
      deviceId = '';
    }
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
