import 'package:kitchen_helper/modules/orders/domain/domain.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late OrderRepository orderRepository;
  late SaveEditingOrderDtoUseCase usecase;

  setUp(() {
    orderRepository = OrderRepositoryMock();
    usecase = SaveEditingOrderDtoUseCase(orderRepository);
  });

  test('WHEN client doesn\'t exist SHOULD create client THEN create order',
      () async {
    final result = await usecase.execute(orderWithNonExistingClient);

    expect(result.isRight(), true);
  });
}

final orderWithNonExistingClient = EditingOrderDto(
  clientId: null,
  client: 'Non existing client',
  contactId: null,
  contact: '',
  address: '',
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
