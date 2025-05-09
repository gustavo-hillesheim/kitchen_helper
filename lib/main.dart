import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device_preview/device_preview.dart' show DevicePreview;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'core/device_info.dart';
import 'app_module.dart';
import 'app_widget.dart';
import 'database/sqlite/sqlite.dart';
import 'firebase_options.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await DeviceInfo.initialize();
      final isPreview =
          !kReleaseMode && (Platform.isWindows || Platform.isMacOS);
      if (!isPreview) {
        await _initializeFirebase();
      }

      await SQLiteDatabase.getInstance();

      runApp(DevicePreview(
        builder: (_) => ModularApp(
          module: AppModule(),
          child: const AppWidget(),
        ),
        enabled: isPreview,
      ));
    },
    // Listens for errors inside the zone
    (e, s) => FirebaseCrashlytics.instance.recordError(e, s),
  );
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseCrashlytics.instance.setUserIdentifier(DeviceInfo.instance.deviceId);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // Listens for errors outside of Flutter
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
}
