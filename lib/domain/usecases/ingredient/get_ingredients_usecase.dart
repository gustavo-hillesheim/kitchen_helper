import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../models/ingredient.dart';
import '../../repository/ingredient_repository.dart';

class GetIngredientsUseCase extends UseCase<NoParams, List<Ingredient>> {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ingredient>>> execute(NoParams input) {
    return repository.findAll();
  }
}
