import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/orders/domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late OrderRepository orderRepository;
  late ClientRepository clientRepository;
  late AddressRepository addressRepository;
  late ContactRepository contactRepository;
  late SaveEditingOrderDtoUseCase usecase;

  setUp(() {
    registerFallbackValue(FakeClient());
    registerFallbackValue(FakeOrder());
    registerFallbackValue(FakeAddressEntity());
    registerFallbackValue(FakeContactEntity());
    orderRepository = OrderRepositoryMock();
    clientRepository = ClientRepositoryMock();
    addressRepository = AddressRepositoryMock();
    contactRepository = ContactRepositoryMock();
    usecase = SaveEditingOrderDtoUseCase(
      orderRepository,
      clientRepository,
      addressRepository,
      contactRepository,
    );
  });

  test('WHEN client doesn\'t exist SHOULD create client THEN create order',
      () async {
    final order = editingOrderWithNonExistingClient;
    when(() => clientRepository.save(Client(
          name: order.clientName!,
          addresses: const [],
          contacts: const [],
        ))).thenAnswer((_) async => const Right(1));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(order);

    expect(
      result.getRight().toNullable(),
      _createOrder(order, id: 2, clientId: 1),
    );
  });

  test('WHEN has Failure on save client SHOULD return Failure', () async {
    final failure = FakeFailure('failure on save client');
    final order = editingOrderWithNonExistingClient;
    when(() => clientRepository.save(any()))
        .thenAnswer((_) async => Left(failure));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(order);

    expect(result.getLeft().toNullable(), failure);
  });

  test('WHEN address doesn\'t exist SHOULD create address THEN create order',
      () async {
    final order = editingOrderWithNonExistingAddress;
    when(() => addressRepository.save(AddressEntity(
          identifier: order.clientAddress!,
          clientId: order.clientId,
        ))).thenAnswer((_) async => const Right(1));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(order);

    expect(
      result.getRight().toNullable(),
      _createOrder(order, id: 2, addressId: 1),
    );
  });

  test('WHEN has Failure on save address SHOULD return Failure', () async {
    final failure = FakeFailure('failure on save address');
    final order = editingOrderWithNonExistingAddress;
    when(() => addressRepository.save(any()))
        .thenAnswer((_) async => Left(failure));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(order);

    expect(result.getLeft().toNullable(), failure);
  });

  test('WHEN contact doesn\'t exist SHOULD create contact THEN create order',
      () async {
    final order = editingOrderWithNonExistingContact;
    when(() => contactRepository.save(ContactEntity(
          contact: order.clientContact!,
          clientId: order.clientId!,
        ))).thenAnswer((_) async => const Right(1));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(order);

    expect(
      result.getRight().toNullable(),
      _createOrder(order, id: 2, contactId: 1),
    );
  });

  test('WHEN has Failure on save contact SHOULD return Failure', () async {
    final failure = FakeFailure('failure on save contact');
    final order = editingOrderWithNonExistingContact;
    when(() => contactRepository.save(any()))
        .thenAnswer((_) async => Left(failure));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(order);

    expect(result.getLeft().toNullable(), failure);
  });

  test('WHEN saves without clientId or clientName SHOULD return Failure',
      () async {
    final order = editingOrderWithoutClientIdAndName;

    final result = await usecase.execute(order);

    expect(
      result.getLeft().toNullable()?.message,
      SaveEditingOrderDtoUseCase.clientIdOrNameAreRequiredMessage,
    );
  });

  test('WHEN saves with clientId and clientName SHOULD return Failure',
      () async {
    final order = editingOrderWithClientIdAndName;

    final result = await usecase.execute(order);

    expect(
      result.getLeft().toNullable()?.message,
      SaveEditingOrderDtoUseCase.cantSaveWithClientNAmeAndIdMessage,
    );
  });

  test('WHEN saves with contactId and clientContact SHOULD return Failure',
      () async {
    final order = editingOrderWithContactIdAndValue;

    final result = await usecase.execute(order);

    expect(
      result.getLeft().toNullable()?.message,
      SaveEditingOrderDtoUseCase.cantSaveWithClientContactAndContactIdMessage,
    );
  });

  test('WHEN saves with addressId and clientAddress SHOULD return Failure',
      () async {
    final order = editingOrderWithAddressIdAndValue;

    final result = await usecase.execute(order);

    expect(
      result.getLeft().toNullable()?.message,
      SaveEditingOrderDtoUseCase.cantSaveWithClientAddressAndAddressIdMessage,
    );
  });

  test('WHEN order has all client ids filled SHOULD only save order', () async {
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(2));
    final order = editingOrderWithAllClientIds;

    final result = await usecase.execute(order);

    expect(result.getRight().toNullable(), _createOrder(order, id: 2));
  });

  test('WHEN order has all client data SHOULD save all THEN save order',
      () async {
    when(() => clientRepository.save(any()))
        .thenAnswer((_) async => const Right(2));
    when(() => addressRepository.save(any()))
        .thenAnswer((_) async => const Right(3));
    when(() => contactRepository.save(any()))
        .thenAnswer((_) async => const Right(4));
    when(() => orderRepository.save(any()))
        .thenAnswer((_) async => const Right(1));
    final order = editingOrderWithAllClientData;

    final result = await usecase.execute(order);

    expect(
        result.getRight().toNullable(),
        _createOrder(
          order,
          id: 1,
          clientId: 2,
          addressId: 3,
          contactId: 4,
        ));
  });
}

Order _createOrder(EditingOrderDto dto,
    {int? id, int? clientId, int? addressId, int? contactId}) {
  return Order(
    id: id ?? dto.id,
    clientId: clientId ?? dto.clientId!,
    contactId: contactId ?? dto.contactId,
    addressId: addressId ?? dto.addressId,
    orderDate: dto.orderDate,
    deliveryDate: dto.deliveryDate,
    status: dto.status,
    products: dto.products.map(_createProduct).toList(),
    discounts: dto.discounts.toList(),
  );
}

OrderProduct _createProduct(EditingOrderProductDto dto) {
  return OrderProduct(id: dto.id, quantity: dto.quantity);
}

final editingOrderWithNonExistingClient = EditingOrderDto(
  clientId: null,
  clientName: 'Non existing client',
  contactId: null,
  clientContact: null,
  clientAddress: null,
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithNonExistingAddress = EditingOrderDto(
  clientId: 1,
  clientName: null,
  contactId: null,
  clientContact: null,
  clientAddress: 'My address',
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithNonExistingContact = EditingOrderDto(
  clientId: 1,
  clientName: null,
  contactId: null,
  clientContact: 'my@contact.com',
  clientAddress: null,
  addressId: 2,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithoutClientIdAndName = EditingOrderDto(
  clientId: null,
  clientName: null,
  contactId: null,
  clientContact: null,
  clientAddress: null,
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithClientIdAndName = EditingOrderDto(
  clientId: 1,
  clientName: 'Some client',
  contactId: null,
  clientContact: null,
  clientAddress: null,
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithContactIdAndValue = EditingOrderDto(
  clientId: 1,
  clientName: null,
  contactId: 1,
  clientContact: 'contact@me.com',
  clientAddress: null,
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithAddressIdAndValue = EditingOrderDto(
  clientId: 1,
  clientName: null,
  contactId: null,
  clientContact: null,
  clientAddress: 'Address',
  addressId: 1,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithAllClientIds = EditingOrderDto(
  clientId: 1,
  clientName: null,
  contactId: 2,
  clientContact: null,
  clientAddress: null,
  addressId: 3,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
final editingOrderWithAllClientData = EditingOrderDto(
  clientId: null,
  clientName: 'Name',
  contactId: null,
  clientContact: 'Contact',
  clientAddress: 'Address',
  addressId: null,
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 2, 1),
  status: OrderStatus.ordered,
  products: const [],
  discounts: const [],
);
