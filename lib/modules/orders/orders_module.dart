import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../ingredients/ingredients_module.dart';
import '../recipes/recipes_module.dart';
import '../clients/clients_module.dart';
import 'data/repository/sqlite_order_discount_repository.dart';
import 'data/repository/sqlite_order_product_repository.dart';
import 'data/repository/sqlite_order_repository.dart';
import 'domain/domain.dart';
import 'presenter/screen/edit_order/edit_order_screen.dart';
import 'presenter/screen/orders_list/orders_list_screen.dart';

class OrdersModule extends Module {
  @override
  List<Module> get imports => [
        RecipesModule(),
        IngredientsModule(),
        ClientsModule(),
      ];

  @override
  void binds(Injector i) {
    i.addLazySingleton<OrderDiscountRepository>(
        SQLiteOrderDiscountRepository.new);
    i.addLazySingleton<OrderProductRepository>(
        SQLiteOrderProductRepository.new);
    i.addLazySingleton<OrderRepository>(SQLiteOrderRepository.new);
    i.addLazySingleton(SaveOrderUseCase.new);
    i.addLazySingleton(GetOrdersUseCase.new);
    i.addLazySingleton(GetOrderUseCase.new);
    i.addLazySingleton(DeleteOrderUseCase.new);
    i.addLazySingleton(GetListingOrderProductsUseCase.new);
    i.addLazySingleton(GetEditingOrderDtoUseCase.new);
    i.addLazySingleton(SaveEditingOrderDtoUseCase.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Modular.initialRoute,
      child: (_) => const OrdersListScreen(),
    );
    r.child('/edit', child: (context) {
      final route = ModalRoute.of(context);
      final arguments = route?.settings.arguments;
      if (arguments is! int?) {
        throw Exception(
            'The route /edit only accepts values of type int? as argument');
      }
      return EditOrderScreen(id: arguments);
    });
  }
}
