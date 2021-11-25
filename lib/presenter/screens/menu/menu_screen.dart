import 'package:flutter/material.dart';

import 'widgets/page_description_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Helper'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            PageDescriptionTile(
              name: 'Ingredientes',
              description: 'Cadastre ingredientes para usar nas suas receitas',
              route: '/ingredients',
              icon: Icons.food_bank_outlined,
              color: Colors.blue,
            ),
            PageDescriptionTile(
              name: 'Receitas',
              description: 'Cadastre receitas para vender',
              route: '/ingredients',
              icon: Icons.fastfood_outlined,
              color: Colors.green,
            ),
            PageDescriptionTile(
              name: 'Pedidos',
              description: 'Cadastre e acompanhe seus pedidos',
              route: '/ingredients',
              icon: Icons.file_copy_outlined,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
