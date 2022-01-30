import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../domain.dart';

class GetOrdersUseCase extends UseCase<OrdersFilter, List<ListingOrderDto>> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingOrderDto>>> execute(OrdersFilter filter) {
    return repository.findAllListing(filter: filter);
  }
}
