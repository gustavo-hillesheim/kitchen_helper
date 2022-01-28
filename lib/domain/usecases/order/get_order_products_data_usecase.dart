import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class GetListingOrderProductsUseCase
    extends UseCase<int, List<ListingOrderProductDto>> {
  final OrderRepository repository;

  GetListingOrderProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingOrderProductDto>>> execute(int orderId) {
    return repository.findAllOrderProductsListing(orderId);
  }
}
