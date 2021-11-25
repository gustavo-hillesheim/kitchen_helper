// ignore_for_file: avoid_renaming_method_parameters

import 'package:fpdart/fpdart.dart';

import '../../core/failure.dart';
import '../../core/usecase.dart';
import '../models/ingredient.dart';
import '../repository/ingredient_repository.dart';

class SaveIngredientUseCase extends UseCase<Ingredient, Ingredient> {
  final IngredientRepository repository;

  SaveIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, Ingredient>> execute(Ingredient ingredient) async {
    if (ingredient.id != null) {
      final result = await repository.update(ingredient);
      if (result.isLeft()) {
        return Left(result.getLeft().toNullable()!);
      }
      return Right(ingredient);
    } else {
      final result = await repository.create(ingredient);
      if (result.isLeft()) {
        return Left(result.getLeft().toNullable()!);
      }
      ingredient = ingredient.copyWith(id: result.getRight().toNullable()!);
      return Right(ingredient);
    }
  }
}
