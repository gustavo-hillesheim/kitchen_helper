import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/presenter/screens/menu/menu_screen.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = createTheme();
    return MaterialApp(
      title: 'Ajudante de cozinha',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: MenuScreen(),
    ).modular();
  }

  ThemeData createTheme() => ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: const TextTheme(
          subtitle2: TextStyle(color: Colors.black54),
          headline4: TextStyle(color: Colors.black87),
          headline5: TextStyle(color: Colors.black87),
          headline6: TextStyle(color: Colors.black87),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );
}
