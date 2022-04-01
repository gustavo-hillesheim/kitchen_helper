import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../clients/clients.dart';
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
  final GetContactsDomainUseCase getContactsDomainUseCase;
  final GetAddressDomainUseCase getAddressDomainUseCase;

  EditOrderBloc(
    this.saveOrderUseCase,
    this.getRecipeUseCase,
    this.getRecipeCostUseCase,
    this.getOrderUseCase,
    this.getContactsDomainUseCase,
    this.getAddressDomainUseCase,
  ) : super(const EmptyState());

  Future<ScreenState<void>> save(EditingOrderDto order) async {
    await runEither(() =>
        saveOrderUseCase.execute(order).onRightThen((_) => const Right(null)));
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

  Future<Either<Failure, List<ContactDomainDto>>> findContactsDomain(
      int clientId) {
    return getContactsDomainUseCase.execute(clientId);
  }

  Future<Either<Failure, List<AddressDomainDto>>> findAddressDomain(
      int clientId) {
    return getAddressDomainUseCase.execute(clientId);
  }
}

class LoadingOrderState extends ScreenState<Order> {
  const LoadingOrderState();
}
