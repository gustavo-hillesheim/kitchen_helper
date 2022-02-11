import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/edit_order_bloc.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/edit_order_screen.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/discount_list.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/general_order_information_form.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/order_products_list.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';
import 'helpers.dart';

void main() {
  late EditOrderBloc bloc;
  late StreamController<ScreenState<void>> streamController;
  ScreenState<void> state = const EmptyState();

  setUp(() {
    registerFallbackValue(FakeOrder());
    registerFallbackValue(FakeOrderProduct());
    registerFallbackValue(FakeEditingOrderDto());
    mockRecipeIngredientsSelectorService();
    streamController = StreamController.broadcast();
    streamController.stream.listen((newState) => state = newState);
    bloc = EditOrderBlocMock();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
    when(() => bloc.state).thenAnswer((_) => state);
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
    await inputOrderInfo(tester, editingSpidermanOrderDto);

    await tester.ensureVisible(find.byType(PrimaryButton).first);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() =>
        bloc.save(editingSpidermanOrderDto.copyWith(address: '', contact: '')));
  });

  testWidgets('WHEN bloc.save returns Failure SHOULD show error message',
      (tester) async {
    when(() => bloc.getEditingOrderProduct(spidermanOrder.products[0]))
        .thenAnswer((_) async =>
            Right(editingOrderProduct(spidermanOrder.products[0])));
    when(() => bloc.save(any())).thenAnswer(
        (_) async => const FailureState((FakeFailure('error message'))));

    await pumpWidget(tester);
    await inputOrderInfo(tester, editingSpidermanOrderDto);

    await tester.tap(find.byType(PrimaryButton).first);
    await tester.pump();
    expect(find.text('error message'), findsOneWidget);

    verify(() =>
        bloc.save(editingSpidermanOrderDto.copyWith(address: '', contact: '')));
  });

  testWidgets('WHEN deletes product SHOULD remove from product list',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDto);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDto);

    await goToProductsTab(tester);
    await delete(tester, find.byType(OrderProductListTile).first);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDto
        .copyWith(products: [], address: '', contact: '')));
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
      return Right(editingSpidermanOrderDto);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDto);

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

    verify(() => bloc.save(editingSpidermanOrderDto.copyWith(products: [
          editingOrderProduct(
            OrderProduct(id: iceCreamRecipe.id!, quantity: 20),
          ),
        ], address: '', contact: '')));
  });

  testWidgets('WHEN deletes discount SHOULD remove from discount list',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDto);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDto);

    await goToDiscountsTab(tester);
    await delete(tester, find.byType(DiscountListTile).first);
    await tester.tap(find.byType(PrimaryButton).first);

    verify(() => bloc.save(editingSpidermanOrderDto
        .copyWith(discounts: [], address: '', contact: '')));
  });

  testWidgets('WHEN edits discount SHOULD update discount list',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const SuccessState(null));
    when(() => bloc.loadOrder(any())).thenAnswer((_) async {
      streamController.sink.add(const SuccessState(null));
      return Right(editingSpidermanOrderDto);
    });

    await pumpWidget(tester, initialValue: editingSpidermanOrderDto);

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

    verify(() => bloc.save(editingSpidermanOrderDto.copyWith(
          discounts: [discount],
          contact: '',
          address: '',
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

class EditOrderBlocMock extends Mock implements EditOrderBloc {}
