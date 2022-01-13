import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';

class OrdersListBloc extends AppCubit<List<Order>> with ListPageBloc<Order> {
  @override
  final GetOrdersUseCase getUseCase;
  @override
  final DeleteOrderUseCase deleteUseCase;
  @override
  final SaveOrderUseCase saveUseCase;

  OrdersListBloc(
    this.getUseCase,
    this.deleteUseCase,
    this.saveUseCase,
  ) : super(const LoadingState());

  @override
  Future<void> load({OrderStatus? status}) async {
    runEither(() => getUseCase.execute(OrdersFilter(
          status: status,
        )));
  }
}
