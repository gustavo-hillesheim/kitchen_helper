import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_module.dart';
import 'presenter/presenter.dart';

void main() {
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
