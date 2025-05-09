import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/app_module.dart';

import 'data/repository/sqlite_ingredient_repository.dart';
import 'ingredients.dart';
import 'presenter/screen/edit_ingredient/edit_ingredient_screen.dart';
import 'presenter/screen/ingredients_list/ingredients_list_screen.dart';

class IngredientsModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<IngredientRepository>(SQLiteIngredientRepository.new);
    i.addLazySingleton(GetIngredientUseCase.new);
    i.addLazySingleton(GetIngredientsUseCase.new);
    i.addLazySingleton(SaveIngredientUseCase.new);
    i.addLazySingleton(DeleteIngredientUseCase.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Modular.initialRoute,
      child: (_) => const IngredientsListScreen(),
    );
    r.child('/edit', child: (context) {
      final route = ModalRoute.of(context);
      final arguments = route?.settings.arguments;
      if (arguments is! int?) {
        throw Exception(
            'The route /edit only accepts values of type int? as argument');
      }
      return EditIngredientScreen(id: arguments);
    });
  }
}
