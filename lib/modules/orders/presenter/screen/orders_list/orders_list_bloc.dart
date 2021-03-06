import '../../../../../common/common.dart';
import '../../../domain/domain.dart';

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
  Future<void> load([OrdersFilter? filter]) async {
    runEither(() => getAllUseCase.execute(filter));
  }
}
