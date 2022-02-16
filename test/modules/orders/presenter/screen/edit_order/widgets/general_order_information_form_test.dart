import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/general_order_information_form.dart';

import '../../../../../../finders.dart';
import '../helpers.dart';

void main() {
  late ValueNotifier<SelectedClient?> clientNotifier;
  late TextEditingController clientContactController;
  late TextEditingController clientAddressController;
  late ValueNotifier<DateTime?> orderDateNotifier;
  late ValueNotifier<DateTime?> deliveryDateNotifier;
  late ValueNotifier<OrderStatus?> statusNotifier;
  const price = 15.0;
  const cost = 5.0;
  const discount = 1.0;

  setUp(() {
    statusNotifier = ValueNotifier(null);
    orderDateNotifier = ValueNotifier(null);
    deliveryDateNotifier = ValueNotifier(null);
    clientNotifier = ValueNotifier(null);
    clientAddressController = TextEditingController();
    clientContactController = TextEditingController();
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GeneralOrderInformationForm(
          statusNotifier: statusNotifier,
          orderDateNotifier: orderDateNotifier,
          deliveryDateNotifier: deliveryDateNotifier,
          clientAddressController: clientAddressController,
          clientContactController: clientContactController,
          clientNotifier: clientNotifier,
          searchClientDomainFn: () async => const Right([
            ClientDomainDto(id: 1, label: 'Test Client'),
          ]),
          price: price,
          cost: cost,
          discount: discount,
        ),
      ),
    ));
  }

  testWidgets('WHEN user inputs info SHOULD update controllers',
      (tester) async {
    await pumpWidget(tester);

    expect(clientNameFinder, findsOneWidget);
    expect(clientContactFinder, findsOneWidget);
    expect(clientAddressFinder, findsOneWidget);
    expect(orderDateFinder, findsOneWidget);
    expect(deliveryDateFinder, findsOneWidget);
    expect(statusFinder, findsOneWidget);

    await inputGeneralOrderInfo(
      tester,
      clientName: 'Test Client',
      clientContact: 'Contact',
      clientAddress: 'Address',
      status: OrderStatus.ordered,
      orderDate: DateTime(2022, 1, 1, 12, 0),
      deliveryDate: DateTime(2022, 2, 1, 15, 30),
    );

    const expectedClient = SelectedClient(id: 1, name: 'Test Client');
    expect(clientNotifier.value, expectedClient);
    expect(clientContactController.text, 'Contact');
    expect(clientAddressController.text, 'Address');
    expect(statusNotifier.value, OrderStatus.ordered);
    expect(orderDateNotifier.value, DateTime(2022, 1, 1, 12, 0));
    expect(deliveryDateNotifier.value, DateTime(2022, 2, 1, 15, 30));
    expectGeneralOrderInformationFormState(
      client: expectedClient,
      clientAddress: 'Address',
      status: OrderStatus.ordered,
      orderDate: DateTime(2022, 1, 1, 12, 0),
      deliveryDate: DateTime(2022, 2, 1, 15, 30),
    );
  });

  testWidgets('WHEN has initialValue SHOULD render fields with initialValue',
      (tester) async {
    const client = SelectedClient(name: 'Test client');
    clientNotifier.value = client;
    clientContactController.text = 'Contact';
    clientAddressController.text = 'Some address';
    statusNotifier.value = OrderStatus.delivered;
    orderDateNotifier.value = DateTime(2022, 10, 1, 9, 15);
    deliveryDateNotifier.value = DateTime(2022, 11, 15, 19, 30);

    await pumpWidget(tester);

    expectGeneralOrderInformationFormState(
      client: client,
      clientContact: 'Contact',
      clientAddress: 'Some address',
      status: OrderStatus.delivered,
      orderDate: DateTime(2022, 10, 1, 9, 15),
      deliveryDate: DateTime(2022, 11, 15, 19, 30),
    );
  });

  testWidgets('SHOULD render calculated values', (tester) async {
    await pumpWidget(tester);

    expect(
      CalculatedValueFinder(
        title: 'Preço',
        value: price - discount,
        calculation: const [
          CalculationStep('Preço base', value: price),
          CalculationStep('Descontos', value: -discount),
        ],
      ),
      findsOneWidget,
    );

    expect(
      CalculatedValueFinder(
        title: 'Lucro',
        value: price - discount - cost,
        calculation: const [
          CalculationStep('Preço', value: price - discount),
          CalculationStep('Custo', value: -cost),
        ],
      ),
      findsOneWidget,
    );
  });
}
