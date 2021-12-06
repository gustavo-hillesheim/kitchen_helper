import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Helper',
      debugShowCheckedModeBanner: false,
      theme: createTheme(),
    ).modular();
  }

  ThemeData createTheme() => ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: const TextTheme(
          subtitle2: TextStyle(color: Colors.black54),
          headline4: TextStyle(color: Colors.black87),
          headline5: TextStyle(color: Colors.black87),
          headline6: TextStyle(color: Colors.black87),
        ),
      );
}
