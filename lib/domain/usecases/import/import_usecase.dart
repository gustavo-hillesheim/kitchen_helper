import 'package:fpdart/fpdart.dart' hide Order;

import '../../../core/core.dart';
import '../../../database/sqlite/sqlite.dart';
import '../../../extensions.dart';
import '../../domain.dart';

class ImportUseCase extends UseCase<Map<String, List>, void> {
  final IngredientRepository ingredientRepository;
  final RecipeRepository recipeRepository;
  final OrderRepository orderRepository;
  final SQLiteDatabase database;

  ImportUseCase(
    this.ingredientRepository,
    this.recipeRepository,
    this.orderRepository,
    this.database,
  );

  @override
  Future<Either<Failure, void>> execute(Map<String, List> input) async {
    return database.insideTransaction<Either<Failure, void>>(() async {
      if (input['ingredients'] != null) {
        for (final ingredientJson in input['ingredients']!) {
          final ingredient = Ingredient.fromJson(ingredientJson);
          await ingredientRepository.save(ingredient).throwOnFailure();
        }
      }
      if (input['recipes'] != null) {
        for (final recipeJson in input['recipes']!) {
          final recipe = Recipe.fromJson(recipeJson);
          await recipeRepository.save(recipe).throwOnFailure();
        }
      }
      if (input['orders'] != null) {
        for (final orderJson in input['orders']!) {
          final order = Order.fromJson(orderJson);
          await orderRepository.save(order).throwOnFailure();
        }
      }
      return const Right(null);
    }).catchError((error) {
      if (error is Failure) {
        return Left(error);
      }
      throw error;
    });
  }
}
