import 'package:flutter_modular/flutter_modular.dart';

import 'app_guard.dart';
import 'data/repository/sqlite_order_discount_repository.dart';
import 'data/repository/sqlite_order_product_repository.dart';
import 'data/repository/sqlite_order_repository.dart';
import 'database/sqlite/sqlite.dart';
import 'domain/domain.dart';
import 'modules/ingredients/ingredients_module.dart';
import 'modules/recipes/recipes_module.dart';
import 'presenter/presenter.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        AsyncBind((i) => SQLiteDatabase.getInstance()),
        Bind<OrderProductRepository>((i) => SQLiteOrderProductRepository(i())),
        Bind<OrderDiscountRepository>(
            (i) => SQLiteOrderDiscountRepository(i())),
        Bind<OrderRepository>((i) => SQLiteOrderRepository(i(), i(), i())),
        Bind((i) => SaveOrderUseCase(i())),
        Bind((i) => GetOrdersUseCase(i())),
        Bind((i) => GetOrderUseCase(i())),
        Bind((i) => DeleteOrderUseCase(i())),
        Bind((i) => GetListingOrderProductsUseCase(i())),
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
        ChildRoute(
          '/orders',
          child: (_, __) => const OrdersListScreen(),
          guards: [AppGuard()],
        ),
        ChildRoute('/edit-order', child: (_, route) {
          if (route.data is! int?) {
            throw Exception('The route /edit-order only accepts values'
                ' of type int? as argument');
          }
          return EditOrderScreen(id: route.data as int?);
        }),
      ];
}
