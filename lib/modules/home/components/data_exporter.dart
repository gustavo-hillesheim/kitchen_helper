import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';

class DataExporter {
  const DataExporter(
    this._clientRepository,
    this._ingredientRepository,
    this._recipeRepository,
    this._orderRepository,
  );

  final ClientRepository _clientRepository;
  final IngredientRepository _ingredientRepository;
  final RecipeRepository _recipeRepository;
  final OrderRepository _orderRepository;

  Future<Map<String, dynamic>> exportData() async {
    final ingredients =
        (await _ingredientRepository.findAll()).getRight().getOrElse(() => []);
    final recipes =
        (await _recipeRepository.findAll()).getRight().getOrElse(() => []);
    final orders =
        (await _orderRepository.findAll()).getRight().getOrElse(() => []);
    final clients =
        (await _clientRepository.findAll()).getRight().getOrElse(() => []);

    return {
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'orders': orders.map((o) => o.toJson()).toList(),
      'clients': clients.map((c) => c.toJson()).toList(),
    };
  }
}
