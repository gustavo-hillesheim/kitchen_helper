import 'package:flutter_modular/flutter_modular.dart';

import 'app_guard.dart';
import 'database/sqlite/sqlite.dart';
import 'modules/home/home_module.dart';
import 'modules/ingredients/ingredients_module.dart';
import 'modules/orders/orders_module.dart';
import 'modules/recipes/recipes_module.dart';
import 'modules/clients/clients_module.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        AsyncBind((i) => SQLiteDatabase.getInstance()),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(
          Modular.initialRoute,
          module: HomeModule(),
        ),
        ModuleRoute(
          '/ingredients',
          module: IngredientsModule(),
          guards: [AppGuard()],
        ),
        ModuleRoute(
          '/recipes',
          module: RecipesModule(),
          guards: [AppGuard()],
        ),
        ModuleRoute(
          '/orders',
          module: OrdersModule(),
          guards: [AppGuard()],
        ),
        ModuleRoute(
          '/clients',
          module: ClientsModule(),
          guards: [AppGuard()],
        ),
      ];
}
