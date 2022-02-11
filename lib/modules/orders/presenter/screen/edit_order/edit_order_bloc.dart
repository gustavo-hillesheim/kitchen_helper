import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../../common/common.dart';
import '../../../../../core/core.dart';
import '../../../../../extensions.dart';
import '../../../../recipes/recipes.dart';
import '../../../domain/domain.dart';

class EditOrderBloc extends AppCubit<void> {
  final SaveEditingOrderDtoUseCase saveOrderUseCase;
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipeCostUseCase getRecipeCostUseCase;
  final GetEditingOrderDtoUseCase getOrderUseCase;

  EditOrderBloc(
    this.saveOrderUseCase,
    this.getRecipeUseCase,
    this.getRecipeCostUseCase,
    this.getOrderUseCase,
  ) : super(const EmptyState());

  Future<ScreenState<void>> save(EditingOrderDto order) async {
    await runEither(() async {
      return saveOrderUseCase.execute(order);
    });
    return state;
  }

  Future<Either<Failure, EditingOrderDto>> loadOrder(int id) async {
    emit(const LoadingOrderState());
    final result = await getOrderUseCase.execute(id);
    result.fold(
      (f) => emit(FailureState(f)),
      (_) => emit(const SuccessState(null)),
    );
    return result;
  }

  Future<Either<Failure, List<EditingOrderProductDto>>> getEditingOrderProducts(
      List<OrderProduct> products) async {
    final futures = products.map(getEditingOrderProduct);
    final values = (await Future.wait(futures)).asEitherList();
    return values;
  }

  Future<Either<Failure, EditingOrderProductDto>> getEditingOrderProduct(
      OrderProduct orderProduct) async {
    return _getEditingOrderProductFromRecipe(orderProduct);
  }

  Future<Either<Failure, EditingOrderProductDto>>
      _getEditingOrderProductFromRecipe(OrderProduct orderProduct) {
    return getRecipeUseCase.execute(orderProduct.id).onRightThen(
          (recipe) => getRecipeCostUseCase.execute(recipe!).onRightThen(
                (recipeCost) => Right(
                  EditingOrderProductDto.fromModels(
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
