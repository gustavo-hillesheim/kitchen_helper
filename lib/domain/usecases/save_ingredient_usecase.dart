// ignore_for_file: avoid_renaming_method_parameters

import 'package:fpdart/fpdart.dart';

import '../../core/failure.dart';
import '../../core/usecase.dart';
import '../data/ingredient_repository.dart';
import '../models/ingredient.dart';

class SaveIngredientUseCase extends UseCase<Ingredient, Ingredient> {
  final IngredientRepository repository;

  SaveIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, Ingredient>> execute(Ingredient ingredient) {
    if (ingredient.id != null) {
      return repository.update(ingredient);
    } else {
      return repository.create(ingredient);
    }
  }
}
