import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';

class OrdersListBloc extends AppCubit<List<ListingOrderDto>>
    with ListPageBloc<ListingOrderDto, Order> {
  @override
  final GetOrdersUseCase getAllUseCase;
  @override
  final DeleteOrderUseCase deleteUseCase;
  @override
  final SaveOrderUseCase saveUseCase;
  @override
  final GetOrderUseCase getUseCase;

  OrdersListBloc(
    this.getAllUseCase,
    this.deleteUseCase,
    this.saveUseCase,
    this.getUseCase,
  ) : super(const LoadingState());

  @override
  Future<void> load({OrderStatus? status}) async {
    runEither(() => getAllUseCase.execute(OrdersFilter(
          status: status,
        )));
  }
}
