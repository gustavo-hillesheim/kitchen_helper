import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../models/ingredient.dart';
import '../../repository/ingredient_repository.dart';

class SaveIngredientUseCase extends UseCase<Ingredient, Ingredient> {
  final IngredientRepository repository;

  SaveIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, Ingredient>> execute(Ingredient ingredient) async {
    return repository
        .save(ingredient)
        .thenEither((id) => ingredient.copyWith(id: id));
  }
}
