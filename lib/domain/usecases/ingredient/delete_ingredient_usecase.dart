import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../repository/ingredient_repository.dart';

class DeleteIngredientUseCase extends UseCase<int, void> {
  static const cantDeleteIngredientWithoutIdMessage =
      'Não é possível excluir um  registro que não foi salvo';

  final IngredientRepository repository;

  DeleteIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(int id) async {
    return repository.deleteById(id);
  }
}
