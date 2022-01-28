import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class GetRecipesDomainUseCase extends UseCase<RecipeFilter?, List<Recipe>> {
  final RecipeRepository repository;

  GetRecipesDomainUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> execute(RecipeFilter? filter) {
    return repository.findAll(filter: filter);
  }
}
