import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/screens/import/import_dialog.dart';

import 'widgets/page_description_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajudante de cozinha'),
      ),
      drawer: Drawer(
        child: ListView(children: [
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (_) => const ImportDialog(),
            ),
            leading: const Icon(Icons.archive),
            title: const Text('Importar'),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            PageDescriptionTile(
              name: 'Ingredientes',
              description: 'Cadastre ingredientes para usar nas suas receitas',
              route: '/ingredients',
              icon: Icons.food_bank_outlined,
            ),
            PageDescriptionTile(
              name: 'Receitas',
              description: 'Cadastre receitas para vender',
              route: '/recipes',
              icon: Icons.food_bank_outlined,
            ),
            PageDescriptionTile(
              name: 'Pedidos',
              description: 'Cadastre e gerencie seus pedidos',
              route: '/orders',
              icon: Icons.receipt_long_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
