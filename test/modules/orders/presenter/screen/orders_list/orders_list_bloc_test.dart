import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/orders_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';

void main() {
  late OrdersListBloc bloc;
  late GetOrdersUseCase getAllUseCase;
  late GetOrderUseCase getUseCase;

  void setup() {
    registerFallbackValue(FakeOrdersFilter());
    getAllUseCase = GetOrdersUseCaseMock();
    getUseCase = GetOrderUseCaseMock();
    bloc = OrdersListBloc(
      getAllUseCase,
      DeleteOrderUseCaseMock(),
      SaveOrderUseCaseMock(),
      getUseCase,
    );
  }

  blocTest<OrdersListBloc, ScreenState<List<ListingOrderDto>>>(
      'WHEN load is called SHOULD call getUseCase with filter',
      setUp: () {
        setup();
        when(() => getAllUseCase.execute(any()))
            .thenAnswer((_) async => Right([listingBatmanOrderDto]));
      },
      build: () => bloc,
      expect: () => <ScreenState<List<ListingOrderDto>>>[
            const LoadingState(),
            SuccessState([listingBatmanOrderDto]),
          ],
      act: (bloc) => bloc.load(
            const OrdersFilter(status: OrderStatus.delivered),
          ),
      verify: (_) {
        verify(
          () => getAllUseCase.execute(const OrdersFilter(
            status: OrderStatus.delivered,
          )),
        );
      });
}
