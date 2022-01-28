import 'package:fpdart/fpdart.dart' hide Order;

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../states.dart';

class OrdersListBloc extends AppCubit<List<ListingOrderDto>> {
  final GetOrdersUseCase getAllUseCase;
  final DeleteOrderUseCase deleteUseCase;
  final SaveOrderUseCase saveUseCase;
  final GetOrderUseCase getUseCase;

  OrdersListBloc(
    this.getAllUseCase,
    this.deleteUseCase,
    this.saveUseCase,
    this.getUseCase,
  ) : super(const LoadingState());

  Future<void> loadOrders({OrderStatus? status}) async {
    runEither(() => getAllUseCase.execute(OrdersFilter(
          status: status,
        )));
  }

  Future<Either<Failure, Order>> delete(int id) async {
    final getResult = await getUseCase.execute(id);
    return getResult.bindFuture<Order>((order) async {
      if (order == null) {
        return const Left(BusinessFailure('Ingrediente não encontrado'));
      }
      return deleteUseCase.execute(id).then((result) {
        loadOrders();
        return result.map((_) => order);
      });
    }).run();
  }

  Future<Either<Failure, Order>> save(Order order) async {
    return saveUseCase.execute(order).then((result) {
      loadOrders();
      return result;
    });
  }
}
