import 'package:fpdart/fpdart.dart';

import '../data/ingredient_repository.dart';
import '../../core/failure.dart';
import '../../core/usecase.dart';
import '../models/ingredient.dart';

class GetIngredientUseCase extends UseCase<String, Ingredient?> {
  final IngredientRepository repository;

  GetIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, Ingredient?>> execute(String id) {
    return repository.findById(id);
  }
}
