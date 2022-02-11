import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/orders/domain/domain.dart';

class GetEditingOrderDtoUseCase extends UseCase<int, EditingOrderDto> {
  @override
  Future<Either<Failure, EditingOrderDto>> execute(int id) {
    throw UnimplementedError();
  }
}
