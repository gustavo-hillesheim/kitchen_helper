import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/common/widget/client_selector_service.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/edit_order_bloc.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/edit_order_screen.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/discount_list.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/general_order_information_form.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/order_products_list.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_test/modular_test.dart';

import '../../../../../mocks.dart';
import 'helpers.dart';

void main() {
  final contact =
      ContactDomainDto(id: 1, label: editingSpidermanOrderDto.clientContact!);
  final address =
      AddressDomainDto(id: 1, label: editingSpidermanOrderDto.clientAddress!);
  late EditOrderBloc bloc;
  late StreamController<ScreenState<void>> streamController;
  late ClientSelectorService clientSelectorService;
  ScreenState<void> state = const EmptyState();

  setUp(() {
    registerFallbackValue(FakeOrder());
    registerFallbackValue(FakeOrderProduct());
    registerFallbackValue(FakeEditingOrderDto());
    mockRecipeIngredientsSelectorService();
    streamController = StreamController.broadcast();
    streamController.stream.listen((newState) => state = newState);
    clientSelectorService = ClientSelectorServiceMock();
    bloc = EditOrderBlocMock();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
    when(() => bloc.state).thenAnswer((_) => state);
    when(() => bloc.findContactsDomain(spidermanClient.id!))
        .thenAnswer((_) async => Right([contact]));
    when(() => bloc.findAddressDomain(spidermanClient.id!))
        .thenAnswer((_) async => Right([address]));
    when(() => clientSelectorService.findClientsDomain())
        .thenAnswer((_) async => Right([
              ClientDomainDto(
                  id: spidermanClient.id!, label: spidermanClient.name),
            ]));
    initModule(FakeModule(clientSelectorService));
  });

  Future<void> pumpWidget(WidgetTester tester,
      {EditingOrderDto? initialValue}) async {
    await tester.pumpWidget(MaterialApp(
      home: EditOrderScreen(
        bloc: bloc,
        id: initialValue?.id,
      ),
    ));
    await tester.pump();
  }

  testWidgets('SHOULD render form, lists and save button', (tester) async {
    await pumpWidget(tester);

    expect(find.text('Novo pedido'), findsOneWidget);
    expect(find.byType(GeneralOrderInformationForm), findsOneWidget);
    await goToProductsTab(tester);
    expect(find.byType(OrderProductsList), findsOneWidget);
    await goToDiscountsTab(tester);
    expect(find.byType(DiscountList), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets('WHEN user inputs order info AND tap save SHOULD call bloc.save',
      (tester) async {
    when(() => bloc.getEditingOrderProduct(spidermanOrder.products[0]))
        .thenAnswer((_) async =>
            Right(editingOrderProduct(spidermanOrder.products[0])));
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));

    await pumpWidget(tester);
    await inputOrderInfo(tester, editingSpidermanOrderDtoWithId);

    await tester.ensureVisible(find.byType(PrimaryButton).first);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDtoWithoutClientDataWithoutId));
  });

  testWidgets('WHEN bloc.save returns Failure SHOULD show error message',
      (tester) async {
    when(() => bloc.getEditingOrderProduct(spidermanOrder.products[0]))
        .thenAnswer((_) async =>
            Right(editingOrderProduct(spidermanOrder.products[0])));
    when(() => bloc.save(any()))
        .thenAnswer((_) async => FailureState((FakeFailure('error message'))));

    await pumpWidget(tester);
    await inputOrderInfo(tester, editingSpidermanOrderDtoWithId);

    await tester.tap(find.byType(PrimaryButton).first);
    await tester.pump();
    expect(find.text('error message'), findsOneWidget);

    verify(() => bloc.save(editingSpidermanOrderDtoWithoutClientDataWithoutId));
  });

  testWidgets('WHEN deletes product SHOULD remove from product list',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDtoWithId);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDtoWithId);

    await goToProductsTab(tester);
    await delete(tester, find.byType(OrderProductListTile).first);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDtoWithoutClientData.copyWith(
          products: [],
        )));
  });

  testWidgets('WHEN edits product SHOULD update product list', (tester) async {
    when(() => bloc.getEditingOrderProduct(any()))
        .thenAnswer((invocation) async {
      final op = invocation.positionalArguments[0];
      return Right(editingOrderProduct(op));
    });
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDtoWithId);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDtoWithId);

    await goToProductsTab(tester);
    await tester.tap(find.byType(OrderProductListTile).first);
    await tester.pumpAndSettle();
    await inputOrderProductInfo(
      tester,
      iceCreamRecipe.name,
      20,
      measurementUnit: iceCreamRecipe.measurementUnit,
    );
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDtoWithoutClientData.copyWith(
          products: [
            editingOrderProduct(
              OrderProduct(id: iceCreamRecipe.id!, quantity: 20),
            ),
          ],
        )));
  });

  testWidgets('WHEN deletes discount SHOULD remove from discount list',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDtoWithId);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDtoWithId);

    await goToDiscountsTab(tester);
    await delete(tester, find.byType(DiscountListTile).first);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDtoWithoutClientData.copyWith(
          discounts: [],
        )));
  });

  testWidgets('WHEN edits discount SHOULD update discount list',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDtoWithId);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDtoWithId);

    const discount = Discount(
      reason: 'Some reason',
      type: DiscountType.percentage,
      value: 25,
    );
    await goToDiscountsTab(tester);
    await tester.tap(find.byType(DiscountListTile).first);
    await tester.pumpAndSettle();
    await inputDiscountInfo(tester, discount);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDtoWithoutClientData.copyWith(
          discounts: [discount],
        )));
  });
}

Future<void> inputOrderInfo(WidgetTester tester, EditingOrderDto order) async {
  await inputGeneralOrderInfo(
    tester,
    clientName: order.clientName,
    clientContact: order.clientContact,
    clientAddress: order.clientAddress,
    status: order.status,
    orderDate: order.orderDate,
    deliveryDate: order.deliveryDate,
  );
  await goToProductsTab(tester);
  for (final product in order.products) {
    final recipe = recipesMap[product.id]!;
    await tester.tap(find.text('Adicionar produto').last);
    await tester.pumpAndSettle();
    await inputOrderProductInfo(
      tester,
      recipe.name,
      product.quantity,
      measurementUnit: recipe.measurementUnit,
    );
  }
  await goToDiscountsTab(tester);
  for (final discount in order.discounts) {
    await tester.tap(find.text('Adicionar desconto').last);
    await tester.pumpAndSettle();
    await inputDiscountInfo(tester, discount);
  }
}

Future<void> goToProductsTab(WidgetTester tester) async {
  await tester.tap(find.text('Produtos'));
  await tester.pumpAndSettle();
}

Future<void> goToDiscountsTab(WidgetTester tester) async {
  await tester.tap(find.byWidgetPredicate(
      (widget) => widget is Tab && widget.text == 'Descontos'));
  await tester.pumpAndSettle();
}

final editingSpidermanOrderDtoWithoutClientData =
    editingSpidermanOrderDtoWithoutClientDataWithoutId.copyWith(
        id: editingSpidermanOrderDtoWithId.id!);
final editingSpidermanOrderDtoWithoutClientDataWithoutId = EditingOrderDto(
  clientId: spidermanClient.id!,
  clientName: null,
  addressId: 1,
  clientAddress: null,
  contactId: 1,
  clientContact: null,
  orderDate: DateTime(2022, 1, 1, 1, 10),
  deliveryDate: DateTime(2022, 1, 2, 15, 30),
  status: OrderStatus.ordered,
  products: [editingOrderProduct(cakeOrderProduct)],
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.percentage, value: 50),
  ],
);

class EditOrderBlocMock extends Mock implements EditOrderBloc {}

class ClientSelectorServiceMock extends Mock implements ClientSelectorService {}

class FakeModule extends Module {
  final ClientSelectorService clientSelectorService;

  FakeModule(this.clientSelectorService);

  @override
  List<Bind<Object>> get binds => [Bind((i) => clientSelectorService)];
}
