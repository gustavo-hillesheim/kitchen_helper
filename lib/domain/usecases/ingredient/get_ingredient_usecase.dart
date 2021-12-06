import 'package:fpdart/fpdart.dart';

import '../../../core/failure.dart';
import '../../../core/usecase.dart';
import '../../models/ingredient.dart';
import '../../repository/ingredient_repository.dart';

class GetIngredientUseCase extends UseCase<int, Ingredient?> {
  final IngredientRepository repository;

  GetIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, Ingredient?>> execute(int id) {
    return repository.findById(id);
  }
}
