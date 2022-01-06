import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../extensions.dart';
import '../../domain.dart';

class SaveRecipeUseCase extends UseCase<Recipe, Recipe> {
  final RecipeRepository repository;

  SaveRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, Recipe>> execute(Recipe recipe) {
    return repository
        .save(recipe)
        .onRightThen((id) => Right(recipe.copyWith(id: id)));
  }
}
