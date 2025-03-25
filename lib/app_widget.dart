import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/app_module.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = createTheme();
    return ModularApp(
      module: AppModule(),
      child: MaterialApp(
        title: 'Ajudante de cozinha',
        debugShowCheckedModeBanner: false,
        theme: theme,
      ),
    );
  }

  ThemeData createTheme() => ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: const TextTheme(
          titleSmall: TextStyle(color: Colors.black54),
          headlineMedium: TextStyle(color: Colors.black87),
          headlineSmall: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );
}
