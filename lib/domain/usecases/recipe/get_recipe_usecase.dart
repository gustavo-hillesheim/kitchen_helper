import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class GetRecipeUseCase extends UseCase<int, Recipe?> {
  final RecipeRepository repository;

  GetRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, Recipe?>> execute(int id) {
    return repository.findById(id);
  }
}
