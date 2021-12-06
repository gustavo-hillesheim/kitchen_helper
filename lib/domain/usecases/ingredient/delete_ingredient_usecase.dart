import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../models/ingredient.dart';
import '../../repository/ingredient_repository.dart';

class DeleteIngredientUseCase extends UseCase<Ingredient, void> {
  static const cantDeleteIngredientWithoutIdMessage =
      'Não é possível excluir um  registro que não foi salvo';

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
