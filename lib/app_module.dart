import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'database/sqlite/sqlite.dart';
import 'modules/home/home_module.dart';
import 'modules/ingredients/ingredients_module.dart';
import 'modules/orders/orders_module.dart';
import 'modules/recipes/recipes_module.dart';
import 'modules/clients/clients_module.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addInstance(Modular.tryGet<SQLiteDatabase>() ?? SQLiteDatabase.instance);
    i.addLazySingleton(() => Dio());
  }

  @override
  void routes(RouteManager r) {
    r.module(
      Modular.initialRoute,
      module: HomeModule(),
    );
    r.module(
      '/ingredients',
      module: IngredientsModule(),
    );
    r.module(
      '/recipes',
      module: RecipesModule(),
    );
    r.module(
      '/orders',
      module: OrdersModule(),
    );
    r.module(
      '/clients',
      module: ClientsModule(),
    );
  }
}
