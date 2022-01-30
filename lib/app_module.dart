import 'package:flutter_modular/flutter_modular.dart';

import 'app_guard.dart';
import 'database/sqlite/sqlite.dart';
import 'modules/ingredients/ingredients_module.dart';
import 'modules/orders/orders_module.dart';
import 'modules/recipes/recipes_module.dart';
import 'presenter/presenter.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        AsyncBind((i) => SQLiteDatabase.getInstance()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(Modular.initialRoute, child: (_, __) => const MenuScreen()),
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
      ];
}
