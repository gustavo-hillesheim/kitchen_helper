import 'package:flutter/material.dart';
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
    try {
      if (input['ingredients'] != null) {
        for (final ingredientJson in input['ingredients']!) {
          debugPrint('Importing ingredient $ingredientJson');
          final ingredient = Ingredient.fromJson(ingredientJson);
          await ingredientRepository.save(ingredient).throwOnFailure();
        }
        debugPrint('Finished importing ingredients');
      }
      if (input['recipes'] != null) {
        for (final recipeJson in input['recipes']!) {
          debugPrint('Importing recipe $recipeJson');
          final recipe = Recipe.fromJson(recipeJson);
          await recipeRepository.save(recipe).throwOnFailure();
        }
        debugPrint('Finished importing recipes');
      }
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    }
    /*return database.insideTransaction<Either<Failure, void>>(() async {
      try {
        if (input['orders'] != null) {
          for (final orderJson in input['orders']!) {
            debugPrint('Importing order $orderJson');
            final order = Order.fromJson(orderJson);
            await orderRepository.save(order).throwOnFailure();
          }
          debugPrint('Finished importing orders');
        }
        return const Right(null);
      } on Failure catch (f) {
        return Left(f);
      }
    });*/
  }
}
