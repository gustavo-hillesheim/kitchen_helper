import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';

import 'app_module.dart';

class AppGuard extends RouteGuard {
  AppGuard() : super();

  @override
  FutureOr<bool> canActivate(String path, ParallelRoute<dynamic> route) async {
    await Modular.isModuleReady<AppModule>();
    return true;
  }
}
