import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../extensions.dart';
import '../model/ingredient.dart';
import '../repository/ingredient_repository.dart';

class SaveIngredientUseCase extends UseCase<Ingredient, Ingredient> {
  final IngredientRepository repository;

  SaveIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, Ingredient>> execute(Ingredient ingredient) async {
    return repository
        .save(ingredient)
        .onRightThen((id) => Right(ingredient.copyWith(id: id)));
  }
}
