import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/data/repository/sqlite_recipe_ingredient_repository.dart';
import 'package:kitchen_helper/data/repository/sqlite_recipe_repository.dart';

import 'app_guard.dart';
import 'core/core.dart';
import 'data/repository/sqlite_ingredient_repository.dart';
import 'domain/domain.dart';
import 'presenter/presenter.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        AsyncBind((i) => SQLiteDatabase.getInstance()),
        Bind<IngredientRepository>((i) => SQLiteIngredientRepository(i())),
        Bind<RecipeIngredientRepository>(
            (i) => SQLiteRecipeIngredientRepository(i())),
        Bind<RecipeRepository>((i) => SQLiteRecipeRepository(i(), i())),
        Bind((i) => SaveIngredientUseCase(i())),
        Bind((i) => GetIngredientsUseCase(i())),
        Bind((i) => GetIngredientUseCase(i())),
        Bind((i) => DeleteIngredientUseCase(i())),
        Bind((i) => SaveRecipeUseCase(i())),
        Bind<GetRecipesUseCase>((i) => GetRecipesUseCase(i())),
        Bind((i) => GetRecipeUseCase(i())),
        Bind((i) => DeleteRecipeUseCase(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(Modular.initialRoute, child: (_, __) => const MenuScreen()),
        ChildRoute(
          '/ingredients',
          child: (_, __) => const IngredientsListScreen(),
          guards: [AppGuard()],
        ),
        ChildRoute(
          '/edit-ingredient',
          child: (_, route) {
            if (route.data is! Ingredient?) {
              throw Exception('The route /edit-ingredient only accepts values'
                  ' of type Ingredient? as argument');
            }
            return EditIngredientScreen(
              initialValue: route.data as Ingredient?,
            );
          },
          guards: [AppGuard()],
        ),
        ChildRoute(
          '/recipes',
          child: (_, __) => const RecipesListScreen(),
          guards: [AppGuard()],
        ),
        ChildRoute('/edit-recipe', child: (_, route) {
          if (route.data is! Recipe?) {
            throw Exception('The route /edit-recipe only accepts values'
                ' of type Recipe? as argument');
          }
          return EditRecipeScreen(
            initialValue: route.data as Recipe?,
          );
        }),
      ];
}
