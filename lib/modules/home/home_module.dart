import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/modules/clients/clients_module.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients_module.dart';
import 'package:kitchen_helper/modules/orders/orders_module.dart';
import 'package:kitchen_helper/modules/recipes/recipes_module.dart';

import 'components/data_exporter.dart';
import 'components/data_importer.dart';
import 'presenter/screen/import_export/import_export_screen.dart';
import 'presenter/screen/menu/menu_screen.dart';

class HomeModule extends Module {
  @override
  List<Module> get imports => [
        ClientsModule(),
        IngredientsModule(),
        RecipesModule(),
        OrdersModule(),
      ];

  @override
  void binds(Injector i) {
    i.addLazySingleton(DataExporter.new);
    i.addLazySingleton(DataImporter.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(Modular.initialRoute, child: (_) => const MenuScreen());
    r.child('/import-export', child: (_) => const ImportExportScreen());
  }
}
