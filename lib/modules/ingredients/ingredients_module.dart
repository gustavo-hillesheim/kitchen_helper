import 'package:flutter_modular/flutter_modular.dart';

import 'data/repository/sqlite_ingredient_repository.dart';
import 'ingredients.dart';
import 'presenter/screen/edit_ingredient/edit_ingredient_screen.dart';
import 'presenter/screen/ingredients_list/ingredients_list_screen.dart';

class IngredientsModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind<IngredientRepository>((i) => SQLiteIngredientRepository(i())),
        Bind((i) => GetIngredientUseCase(i())),
        Bind((i) => GetIngredientsUseCase(i())),
        Bind((i) => SaveIngredientUseCase(i())),
        Bind((i) => DeleteIngredientUseCase(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const IngredientsListScreen(),
        ),
        ChildRoute('/edit', child: (_, route) {
          if (route.data is! int?) {
            throw Exception(
                'The route /edit only accepts values of type int? as argument');
          }
          return EditIngredientScreen(id: route.data as int?);
        }),
      ];
}
