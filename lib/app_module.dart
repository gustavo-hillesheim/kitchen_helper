import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/presenter/screens/edit_ingredient/edit_ingredient_screen.dart';
import 'package:kitchen_helper/presenter/screens/menu/menu_screen.dart';

import 'presenter/screens/ingredients_list/ingredients_list_screen.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(Modular.initialRoute, child: (_, __) => const MenuScreen()),
        ChildRoute('/ingredients', child: (_, __) => IngredientsListScreen()),
        ChildRoute('/edit-ingredient',
            child: (_, __) => EditIngredientScreen()),
      ];
}
