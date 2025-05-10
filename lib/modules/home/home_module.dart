import 'package:flutter_modular/flutter_modular.dart';

import 'presenter/screen/import_export/import_export_screen.dart';
import 'presenter/screen/menu/menu_screen.dart';

class HomeModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(Modular.initialRoute, child: (_) => const MenuScreen());
    r.child('/import-export', child: (_) => const ImportExportScreen());
  }
}
