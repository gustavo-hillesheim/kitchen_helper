import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_helper/core/device_info.dart';

class DeviceIdTile extends StatelessWidget {
  const DeviceIdTile({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceId = DeviceInfo.instance.deviceId;
    return ListTile(
      onTap: () {
        Clipboard.setData(ClipboardData(text: deviceId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('ID Copiado!')),
          ),
        );
      },
      title: Text('Seu ID: $deviceId'),
    );
  }
}
