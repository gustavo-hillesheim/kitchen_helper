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
  Future<void> load({bool isDelivered = false}) async {
    super.load();
  }
}
