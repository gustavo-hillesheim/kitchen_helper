import 'package:flutter_modular/flutter_modular.dart';

import 'presenter/screen/menu/menu_screen.dart';

class HomeModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(Modular.initialRoute, child: (_) => const MenuScreen());
  }
}
