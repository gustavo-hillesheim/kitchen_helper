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
    emit(const LoadingState());
    await Future.delayed(const Duration(seconds: 1));
    emit(SuccessState(
      [
        if (!isDelivered)
          Order(
            id: 1,
            clientName: 'Josiane',
            clientAddress: 'Erwin Henschel, 643',
            orderDate: DateTime(2022, 1, 11, 10, 30),
            deliveryDate: DateTime(2022, 1, 15, 8),
            status: OrderStatus.ordered,
            products: const [
              OrderProduct(id: 1, quantity: 10),
              OrderProduct(id: 2, quantity: 5),
            ],
          ),
        Order(
          id: 1,
          clientName: 'Leonardo',
          clientAddress: 'Vila nova - Theodoro Holtrup, 123',
          orderDate: DateTime(2021, 12, 20, 10, 27),
          deliveryDate: DateTime(2021, 12, 24, 17, 30),
          status: OrderStatus.delivered,
          products: const [
            OrderProduct(id: 1, quantity: 100),
            OrderProduct(id: 2, quantity: 5),
            OrderProduct(id: 3, quantity: 1),
            OrderProduct(id: 4, quantity: 2),
            OrderProduct(id: 5, quantity: 1),
            OrderProduct(id: 6, quantity: 1),
          ],
        ),
      ],
    ));
  }
}
