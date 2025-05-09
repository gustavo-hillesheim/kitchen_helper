import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = createTheme();
    return MaterialApp.router(
      routerConfig: Modular.routerConfig,
      title: 'Ajudante de cozinha',
      debugShowCheckedModeBanner: false,
      theme: theme,
    );
  }

  ThemeData createTheme() => ThemeData(
        useMaterial3: false,
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
