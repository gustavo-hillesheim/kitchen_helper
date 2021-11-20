import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/screens/menu/widgets/page_description_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text(
          'Kitchen Helper',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            PageDescriptionTile(
              name: 'Ingredientes',
              description: 'Cadastre ingredientes para usar nas suas receitas',
              icon: Icons.food_bank_outlined,
              color: Colors.blue,
            ),
            PageDescriptionTile(
              name: 'Receitas',
              description: 'Cadastre receitas para vender',
              icon: Icons.fastfood_outlined,
              color: Colors.green,
            ),
            PageDescriptionTile(
              name: 'Pedidos',
              description: 'Cadastre e acompanhe seus pedidos',
              icon: Icons.file_copy_outlined,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
