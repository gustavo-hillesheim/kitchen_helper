import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'device_id_tile.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ScaffoldMessenger(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                ListTile(
                  onTap: () => Modular.to.pushNamed('/import-export'),
                  title: Text('Importar/Exportar dados'),
                ),
                const Spacer(),
                const DeviceIdTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
