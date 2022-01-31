import 'package:flutter_modular/flutter_modular.dart';

import 'presenter/screen/menu/menu_screen.dart';

class HomeModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(Modular.initialRoute, child: (_, __) => const MenuScreen()),
      ];
}
