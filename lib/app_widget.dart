import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.grey.shade100,
      textTheme: const TextTheme(
        subtitle2: TextStyle(color: Colors.black54),
        headline5: TextStyle(color: Colors.black87),
        headline6: TextStyle(color: Colors.black87),
      ),
    );
    return MaterialApp(
      title: 'Kitchen Helper',
      theme: theme,
    ).modular();
  }
}
