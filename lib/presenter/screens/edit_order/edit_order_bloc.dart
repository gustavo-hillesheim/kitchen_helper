import 'package:fpdart/fpdart.dart' hide Order;

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../extensions.dart';
import '../states.dart';
import 'models/editing_order_product.dart';

class EditOrderBloc extends AppCubit<Order> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipeCostUseCase getRecipeCostUseCase;

  EditOrderBloc(
    this.saveOrderUseCase,
    this.getRecipeUseCase,
    this.getRecipeCostUseCase,
  ) : super(const EmptyState());

  Future<ScreenState<void>> save(Order order) async {
    await runEither(() => saveOrderUseCase.execute(order));
    return state;
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
