import 'package:flutter_modular/flutter_modular.dart';

import '../ingredients/ingredients_module.dart';
import '../recipes/recipes_module.dart';
import 'data/repository/sqlite_order_discount_repository.dart';
import 'data/repository/sqlite_order_product_repository.dart';
import 'data/repository/sqlite_order_repository.dart';
import 'domain/domain.dart';
import 'presenter/screen/edit_order/edit_order_screen.dart';
import 'presenter/screen/orders_list/orders_list_screen.dart';

class OrdersModule extends Module {
  @override
  List<Module> get imports => [RecipesModule(), IngredientsModule()];

  @override
  List<Bind<Object>> get binds => [
        Bind<OrderDiscountRepository>(
            (i) => SQLiteOrderDiscountRepository(i())),
        Bind<OrderProductRepository>((i) => SQLiteOrderProductRepository(i())),
        Bind<OrderRepository>((i) => SQLiteOrderRepository(i(), i(), i())),
        Bind((i) => SaveOrderUseCase(i())),
        Bind((i) => GetOrdersUseCase(i())),
        Bind((i) => GetOrderUseCase(i())),
        Bind((i) => DeleteOrderUseCase(i())),
        Bind((i) => GetListingOrderProductsUseCase(i())),
        Bind((i) => GetEditingOrderDtoUseCase(i())),
        Bind((i) => SaveEditingOrderDtoUseCase(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const OrdersListScreen(),
        ),
        ChildRoute('/edit', child: (_, route) {
          if (route.data is! int?) {
            throw Exception(
                'The route /edit only accepts values of type int? as argument');
          }
          return EditOrderScreen(id: route.data as int?);
        })
      ];
}
