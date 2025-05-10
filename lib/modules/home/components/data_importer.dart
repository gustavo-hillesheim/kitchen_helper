import 'package:kitchen_helper/database/entity.dart';
import 'package:kitchen_helper/database/repository.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';

class DataImporter {
  const DataImporter(
    this._clientRepository,
    this._ingredientRepository,
    this._recipeRepository,
    this._orderRepository,
  );

  final ClientRepository _clientRepository;
  final IngredientRepository _ingredientRepository;
  final RecipeRepository _recipeRepository;
  final OrderRepository _orderRepository;

  Future<void> importData(Map<String, dynamic> data) async {
    await _importIngredients(data['ingredients']);
    await _importRecipes(data['recipes']);
    await _importClients(data['clients']);
    await _importOrders(data['orders']);
  }

  Future<void> _importIngredients(dynamic ingredients) async {
    if (ingredients is! List || ingredients.isEmpty) return;
    final parsedIngredients = _parseEntities(ingredients, Ingredient.fromJson);
    await _importEntities(parsedIngredients, _ingredientRepository);
  }

  Future<void> _importRecipes(dynamic recipes) async {
    if (recipes is! List || recipes.isEmpty) return;
    final parsedRecipes = _parseEntities(recipes, Recipe.fromJson);
    await _importEntities(parsedRecipes, _recipeRepository);
  }

  Future<void> _importClients(dynamic clients) async {
    if (clients is! List || clients.isEmpty) return;
    final parsedClients = _parseEntities(clients, Client.fromJson);
    await _importEntities(parsedClients, _clientRepository);
  }

  Future<void> _importOrders(dynamic orders) async {
    if (orders is! List || orders.isEmpty) return;
    final parsedOrders = _parseEntities(orders, Order.fromJson);
    await _importEntities(parsedOrders, _orderRepository);
  }

  Iterable<T> _parseEntities<T extends Entity>(
    List data,
    T Function(Map<String, dynamic>) parser,
  ) {
    return data
        .whereType<Map>()
        .map((j) => j.cast<String, dynamic>())
        .map((j) => parser(j));
  }

  Future<void> _importEntities<T extends Entity<ID>, ID>(
    Iterable<T> entities,
    Repository<T, ID> repository,
  ) async {
    if (entities.isEmpty) return;
    final existingEntities = await repository.findAll();
    final existingEntitiesIds = existingEntities.foldRight(
      <ID>{},
      (_, entities) => entities.map((e) => e.id).whereType<ID>().toSet(),
    );
    final entitiesToAdd =
        entities.where((i) => !existingEntitiesIds.contains(i.id));
    for (final entity in entitiesToAdd) {
      await repository.save(entity);
    }
  }
}
