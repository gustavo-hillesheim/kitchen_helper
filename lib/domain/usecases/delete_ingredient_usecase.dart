import 'package:fpdart/fpdart.dart';

import '../../core/failure.dart';
import '../../core/usecase.dart';
import '../models/ingredient.dart';
import '../repository/ingredient_repository.dart';

class DeleteIngredientUseCase extends UseCase<Ingredient, void> {
  static const cantDeleteIngredientWithoutIdMessage =
      'Can\'t delete ingredient without an id';

  final IngredientRepository repository;

  DeleteIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Ingredient ingredient) async {
    if (ingredient.id == null) {
      return Left(BusinessFailure(cantDeleteIngredientWithoutIdMessage));
    }
    return repository.deleteById(ingredient.id!);
  }
}