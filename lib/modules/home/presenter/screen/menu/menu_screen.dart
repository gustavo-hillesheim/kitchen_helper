import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_helper/core/device_info.dart';

import 'widgets/page_description_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajudante de cozinha'),
        actions: [
          IconButton(
            onPressed: () {
              final deviceId = DeviceInfo.instance.deviceId;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Seu ID: $deviceId'),
                  action: SnackBarAction(
                    label: 'Copiar',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: deviceId));
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bug_report_outlined),
          ),
        ],
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
