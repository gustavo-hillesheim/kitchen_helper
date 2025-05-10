import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/app_module.dart';

import '../ingredients/ingredients_module.dart';
import 'data/repository/sqlite_recipe_ingredient_repository.dart';
import 'data/repository/sqlite_recipe_repository.dart';
import 'domain/domain.dart';
import 'presenter/screen/edit_recipe/edit_recipe_screen.dart';
import 'presenter/screen/recipes_list/recipes_list_screen.dart';

class RecipesModule extends Module {
  @override
  List<Module> get imports => [IngredientsModule(), AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<RecipeIngredientRepository>(
      SQLiteRecipeIngredientRepository.new,
    );
    i.addSingleton<RecipeRepository>(
      SQLiteRecipeRepository.new,
    );
    i.addSingleton(SaveRecipeUseCase.new);
    i.addSingleton(GetRecipesUseCase.new);
    i.addSingleton(GetRecipeUseCase.new);
    i.addSingleton(DeleteRecipeUseCase.new);
    i.addSingleton(GetRecipeCostUseCase.new);
    i.addSingleton(GetRecipesDomainUseCase.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Modular.initialRoute,
      child: (_) => const RecipesListScreen(),
    );
    r.child(
      '/edit',
      child: (_) {
        final arguments = Modular.args.data;
        if (arguments is! int?) {
          throw Exception(
              'The route /edit only accepts values of type int? as argument');
        }
        return EditRecipeScreen(id: arguments);
      },
    );
  }
}
