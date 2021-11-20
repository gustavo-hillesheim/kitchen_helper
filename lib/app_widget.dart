import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/screens/menu/menu_screen.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
