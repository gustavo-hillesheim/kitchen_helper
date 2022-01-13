import 'package:fpdart/fpdart.dart' hide Order;

import '../../../core/core.dart';
import '../../../extensions.dart';
import '../../domain.dart';

class GetOrderPriceUseCase extends UseCase<Order, double> {
  final GetRecipeUseCase getRecipeUseCase;

  GetOrderPriceUseCase(this.getRecipeUseCase);

  @override
  Future<Either<Failure, double>> execute(Order order) async {
    final futures = order.products.map(_getPrice);
    final values = (await Future.wait(futures)).asEitherList();
    return values.map((prices) => prices.fold(0, (a, b) => a + b));
  }

  Future<Either<Failure, double>> _getPrice(OrderProduct product) {
    return getRecipeUseCase.execute(product.id).onRightThen(
          (recipe) =>
              Right(recipe!.price! * (product.quantity / recipe.quantitySold!)),
        );
  }
}
