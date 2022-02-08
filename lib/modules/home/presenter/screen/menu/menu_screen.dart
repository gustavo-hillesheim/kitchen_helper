import 'package:flutter/material.dart';

import 'widgets/page_description_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajudante de cozinha'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            PageDescriptionTile(
              name: 'Ingredientes',
              description: 'Cadastre ingredientes para usar nas suas receitas',
              route: '/ingredients/',
              icon: Icons.food_bank_outlined,
            ),
            PageDescriptionTile(
              name: 'Receitas',
              description: 'Cadastre receitas para vender',
              route: '/recipes/',
              icon: Icons.food_bank_outlined,
            ),
            PageDescriptionTile(
              name: 'Pedidos',
              description: 'Cadastre e gerencie seus pedidos',
              route: '/orders/',
              icon: Icons.receipt_long_outlined,
            ),
            PageDescriptionTile(
              name: 'Clientes',
              description: 'Cadastre os dados dos seus clientes',
              route: '/clients/',
              icon: Icons.people_outline,
            ),
          ],
        ),
      ),
    );
  }
}