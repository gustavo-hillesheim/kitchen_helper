import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';

import 'app_guard.dart';
import 'core/sqlite/sqlite_database.dart';
import 'data/repository/sqlite_ingredient_repository.dart';
import 'domain/repository/ingredient_repository.dart';
import 'domain/usecases/delete_ingredient_usecase.dart';
import 'domain/usecases/get_ingredient_usecase.dart';
import 'domain/usecases/get_ingredients_usecase.dart';
import 'domain/usecases/save_ingredient_usecase.dart';
import 'presenter/screens/edit_ingredient/edit_ingredient_screen.dart';
import 'presenter/screens/ingredients_list/ingredients_list_screen.dart';
import 'presenter/screens/menu/menu_screen.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        AsyncBind((i) => SQLiteDatabase.getInstance()),
        Bind<IngredientRepository>((i) => SQLiteIngredientRepository(i())),
        Bind((i) => SaveIngredientUseCase(i())),
        Bind((i) => GetIngredientsUseCase(i())),
        Bind((i) => GetIngredientUseCase(i())),
        Bind((i) => DeleteIngredientUseCase(i())),
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
      ];
}
