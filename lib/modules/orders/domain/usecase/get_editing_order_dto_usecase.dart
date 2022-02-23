import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../domain.dart';

class GetEditingOrderDtoUseCase extends UseCase<int, EditingOrderDto> {
  static const couldntFindEntityMessage = 'O pedido não foi encontrado';

  final OrderRepository repository;

  GetEditingOrderDtoUseCase(this.repository);

  @override
  Future<Either<Failure, EditingOrderDto>> execute(int id) async {
    final result = await repository.findEditingDtoById(id);
    return result.bind((e) {
      if (e == null) {
        return const Left(BusinessFailure(couldntFindEntityMessage));
      }
      return Right(e);
    });
  }
}
