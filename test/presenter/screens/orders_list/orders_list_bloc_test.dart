import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/orders_list/orders_list_bloc.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late OrdersListBloc bloc;
  late GetOrdersUseCase getUseCase;

  void setup() {
    registerFallbackValue(FakeOrdersFilter());
    getUseCase = GetOrdersUseCaseMock();
    bloc = OrdersListBloc(
      getUseCase,
      DeleteOrderUseCaseMock(),
      SaveOrderUseCaseMock(),
    );
  }

  blocTest<OrdersListBloc, ScreenState<List<Order>>>(
      'WHEN load is called SHOULD call getUseCase with filter',
      setUp: () {
        setup();
        when(() => getUseCase.execute(any()))
            .thenAnswer((_) async => Right([batmanOrder]));
      },
      build: () => bloc,
      expect: () => <ScreenState<List<Order>>>[
            const LoadingState(),
            SuccessState([batmanOrder]),
          ],
      act: (bloc) => bloc.load(status: OrderStatus.delivered),
      verify: (_) {
        verify(
          () => getUseCase.execute(const OrdersFilter(
            status: OrderStatus.delivered,
          )),
        );
      });
}
