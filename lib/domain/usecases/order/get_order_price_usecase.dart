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
    return values.map((prices) => prices.fold(0.0, sum)).map((price) {
      return price - calculateDiscounts(order, price);
    });
  }

  double sum(double a, double b) => a + b;

  double calculateDiscounts(Order order, double price) {
    return order.discounts.map((d) => d.calculate(price)).fold(0.0, sum);
  }

  Future<Either<Failure, double>> _getPrice(OrderProduct product) {
    return getRecipeUseCase.execute(product.id).onRightThen(
          (recipe) =>
              Right(recipe!.price! * (product.quantity / recipe.quantitySold!)),
        );
  }
}
