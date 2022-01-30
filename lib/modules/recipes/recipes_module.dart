import 'package:flutter_modular/flutter_modular.dart';

import '../ingredients/ingredients_module.dart';
import 'data/repository/sqlite_recipe_ingredient_repository.dart';
import 'data/repository/sqlite_recipe_repository.dart';
import 'domain/domain.dart';
import 'presenter/edit_recipe/edit_recipe_screen.dart';
import 'presenter/recipes_list/recipes_list_screen.dart';

class RecipesModule extends Module {
  @override
  List<Module> get imports => [IngredientsModule()];

  @override
  List<Bind<Object>> get binds => [
        Bind<RecipeIngredientRepository>(
            (i) => SQLiteRecipeIngredientRepository(i())),
        Bind<RecipeRepository>((i) => SQLiteRecipeRepository(i(), i())),
        Bind((i) => SaveRecipeUseCase(i())),
        Bind((i) => GetRecipesUseCase(i())),
        Bind((i) => GetRecipeUseCase(i())),
        Bind((i) => DeleteRecipeUseCase(i())),
        Bind((i) => GetRecipeCostUseCase(i(), i())),
        Bind((i) => GetRecipesDomainUseCase(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const RecipesListScreen(),
        ),
        ChildRoute(
          '/edit',
          child: (_, route) {
            if (route.data is! int?) {
              throw Exception(
                  'The route /edit only accepts values of type int? as argument');
            }
            return EditRecipeScreen(id: route.data as int?);
          },
        )
      ];
}
