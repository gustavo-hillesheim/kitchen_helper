import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/core.dart';
import '../../../../domain/domain.dart';
import '../../../../extensions.dart';
import '../../states.dart';

class OrderListTileBloc extends AppCubit<List<OrderProductData>> {
  final GetRecipeUseCase getRecipeUseCase;
  final GetOrderPriceUseCase getOrderPriceUseCase;

  OrderListTileBloc(
    this.getRecipeUseCase,
    this.getOrderPriceUseCase,
  ) : super(const EmptyState());

  Future<void> loadProducts(Order order) async {
    runEither(() => _loadProductsData(order));
  }

  Future<Either<Failure, double>> getPrice(Order order) async {
    return getOrderPriceUseCase.execute(order);
  }

  Future<Either<Failure, List<OrderProductData>>> _loadProductsData(
      Order order) async {
    final futures = order.products.map(_loadProductData);
    final values = (await Future.wait(futures)).asEitherList();
    return values;
  }

  Future<Either<Failure, OrderProductData>> _loadProductData(
      OrderProduct product) {
    return getRecipeUseCase
        .execute(product.id)
        .onRightThen<Failure, Recipe>(
          (recipe) async => recipe != null
              ? Right(recipe)
              : const Left(
                  BusinessFailure('Não foi possível encontrar o produto')),
        )
        .onRightThen((recipe) => Right(OrderProductData(
              quantity: product.quantity,
              measurementUnit: recipe.measurementUnit,
              name: recipe.name,
            )));
  }
}

class OrderProductData {
  final double quantity;
  final MeasurementUnit measurementUnit;
  final String name;

  OrderProductData({
    required this.quantity,
    required this.measurementUnit,
    required this.name,
  });
}
