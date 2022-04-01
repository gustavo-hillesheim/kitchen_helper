import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/common/widget/client_selector_service.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/general_order_information_form.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_test/modular_test.dart';

import '../../../../../../finders.dart';
import '../../../../../../mocks.dart';
import '../helpers.dart';

void main() {
  late ValueNotifier<SelectedClient?> clientNotifier;
  late ValueNotifier<SelectedContact?> contactNotifier;
  late ValueNotifier<SelectedAddress?> addressNotifier;
  late ValueNotifier<DateTime?> orderDateNotifier;
  late ValueNotifier<DateTime?> deliveryDateNotifier;
  late ValueNotifier<OrderStatus?> statusNotifier;
  late GetClientsDomainUseCase getClientsDomainUseCase;
  const price = 15.0;
  const cost = 5.0;
  const discount = 1.0;

  setUp(() {
    statusNotifier = ValueNotifier(null);
    orderDateNotifier = ValueNotifier(null);
    deliveryDateNotifier = ValueNotifier(null);
    clientNotifier = ValueNotifier(null);
    contactNotifier = ValueNotifier(null);
    addressNotifier = ValueNotifier(null);
    getClientsDomainUseCase = GetClientsDomainUseCaseMock();
    when(() => getClientsDomainUseCase.execute(const NoParams()))
        .thenAnswer((_) async => const Right([
              ClientDomainDto(id: 1, label: 'Test Client'),
            ]));
    initModule(FakeModule(getClientsDomainUseCase));
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GeneralOrderInformationForm(
          statusNotifier: statusNotifier,
          orderDateNotifier: orderDateNotifier,
          deliveryDateNotifier: deliveryDateNotifier,
          contactNotifier: contactNotifier,
          clientNotifier: clientNotifier,
          addressNotifier: addressNotifier,
          searchContactDomainFn: () async =>
              const Right([ContactDomainDto(id: 1, label: 'Contact')]),
          searchAddressDomainFn: () async =>
              const Right([AddressDomainDto(id: 1, label: 'Address')]),
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
    const expectedContact = SelectedContact(id: 1, contact: 'Contact');
    const expectedAddress = SelectedAddress(id: 1, identifier: 'Address');
    expect(clientNotifier.value, expectedClient);
    expect(contactNotifier.value, expectedContact);
    expect(addressNotifier.value, expectedAddress);
    expect(statusNotifier.value, OrderStatus.ordered);
    expect(orderDateNotifier.value, DateTime(2022, 1, 1, 12, 0));
    expect(deliveryDateNotifier.value, DateTime(2022, 2, 1, 15, 30));
    expectGeneralOrderInformationFormState(
      client: expectedClient,
      contact: expectedContact,
      address: expectedAddress,
      status: OrderStatus.ordered,
      orderDate: DateTime(2022, 1, 1, 12, 0),
      deliveryDate: DateTime(2022, 2, 1, 15, 30),
    );
  });

  testWidgets('WHEN has initialValue SHOULD render fields with initialValue',
      (tester) async {
    const client = SelectedClient(name: 'Test client');
    const contact = SelectedContact(contact: 'test@contact.com');
    const address = SelectedAddress(identifier: 'Test address');
    clientNotifier.value = client;
    contactNotifier.value = contact;
    addressNotifier.value = address;
    statusNotifier.value = OrderStatus.delivered;
    orderDateNotifier.value = DateTime(2022, 10, 1, 9, 15);
    deliveryDateNotifier.value = DateTime(2022, 11, 15, 19, 30);

    await pumpWidget(tester);

    expectGeneralOrderInformationFormState(
      client: client,
      contact: contact,
      address: address,
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

class FakeModule extends Module {
  final GetClientsDomainUseCase getClientsDomainUseCase;

  FakeModule(this.getClientsDomainUseCase);

  @override
  List<Bind<Object>> get binds => [
        Bind((i) => ClientSelectorService(getClientsDomainUseCase)),
      ];
}
