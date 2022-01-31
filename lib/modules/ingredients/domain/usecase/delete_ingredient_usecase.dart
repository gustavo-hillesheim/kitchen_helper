import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../repository/ingredient_repository.dart';

class DeleteIngredientUseCase extends UseCase<int, void> {
  final IngredientRepository repository;

  DeleteIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(int id) async {
    return repository.deleteById(id);
  }
}
