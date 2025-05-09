import 'package:flutter/material.dart';

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
