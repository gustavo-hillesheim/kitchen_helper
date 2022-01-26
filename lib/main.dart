import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_module.dart';
import 'presenter/presenter.dart';

void main() {
  runApp(DevicePreview(
    builder: (_) => ModularApp(module: AppModule(), child: const AppWidget()),
    enabled: !kReleaseMode,
  ));
}
