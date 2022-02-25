import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device_preview/device_preview.dart' show DevicePreview;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/core/device_info.dart';

import 'app_module.dart';
import 'app_widget.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      await DeviceInfo.initialize();

      FirebaseCrashlytics.instance
          .setUserIdentifier(DeviceInfo.instance.deviceId);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      // Listens for errors outside of Flutter
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
        );
      }).sendPort);

      runApp(DevicePreview(
        builder: (_) =>
            ModularApp(module: AppModule(), child: const AppWidget()),
        enabled: !kReleaseMode && Platform.isWindows,
      ));
    },
    // Listens for errors inside the zone
    (e, s) => FirebaseCrashlytics.instance.recordError(e, s),
  );
}
