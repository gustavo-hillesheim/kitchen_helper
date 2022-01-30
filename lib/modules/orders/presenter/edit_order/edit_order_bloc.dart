import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/core.dart';
import '../../../../extensions.dart';
import '../../../../presenter/screens/states.dart';
import '../../../recipes/recipes.dart';
import '../../domain/domain.dart';
import 'models/editing_order_product.dart';

class EditOrderBloc extends AppCubit<Order> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipeCostUseCase getRecipeCostUseCase;
  final GetOrderUseCase getOrderUseCase;

  EditOrderBloc(
    this.saveOrderUseCase,
    this.getRecipeUseCase,
    this.getRecipeCostUseCase,
    this.getOrderUseCase,
  ) : super(const EmptyState());

  Future<ScreenState<void>> save(Order order) async {
    await runEither(() async {
      return saveOrderUseCase.execute(order);
    });
    return state;
  }

  Future<void> loadOrder(int id) async {
    emit(const LoadingOrderState());
    final result = await getOrderUseCase.execute(id);
    result.fold(
      (f) => emit(FailureState(f)),
      (order) {
        if (order == null) {
          emit(const FailureState(
            BusinessFailure('Não foi possível encontrar o pedido'),
          ));
        } else {
          emit(SuccessState(order));
        }
      },
    );
  }

  Future<Either<Failure, List<EditingOrderProduct>>> getEditingOrderProducts(
      List<OrderProduct> products) async {
    final futures = products.map(getEditingOrderProduct);
    final values = (await Future.wait(futures)).asEitherList();
    return values;
  }

  Future<Either<Failure, EditingOrderProduct>> getEditingOrderProduct(
      OrderProduct orderProduct) async {
    return _getEditingOrderProductFromRecipe(orderProduct);
  }

  Future<Either<Failure, EditingOrderProduct>>
      _getEditingOrderProductFromRecipe(OrderProduct orderProduct) {
    return getRecipeUseCase.execute(orderProduct.id).onRightThen(
          (recipe) => getRecipeCostUseCase.execute(recipe!).onRightThen(
                (recipeCost) => Right(
                  EditingOrderProduct.fromModels(
                    orderProduct,
                    recipe,
                    recipeCost,
                  ),
                ),
              ),
        );
  }
}

class LoadingOrderState extends ScreenState<Order> {
  const LoadingOrderState();
}
