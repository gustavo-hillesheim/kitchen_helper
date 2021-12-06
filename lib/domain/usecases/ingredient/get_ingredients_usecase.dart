import 'package:fpdart/fpdart.dart';

import '../../../core/failure.dart';
import '../../../core/usecase.dart';
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
