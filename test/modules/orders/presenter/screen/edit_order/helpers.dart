import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/general_order_information_form.dart';

import '../../../../../finders.dart';
import '../../../../../utils.dart';

const discountOne =
    Discount(reason: 'Reason', type: DiscountType.fixed, value: 10);
const discountTwo =
    Discount(reason: 'Reason 2', type: DiscountType.percentage, value: 10);

final reasonFinder = AppTextFormFieldFinder(name: 'Motivo', value: null);
final typeSelectorFinder =
    find.byWidgetPredicate((widget) => widget is DropdownButton<DiscountType>);

Finder getValueFinder(DiscountType type) {
  final name = type.label;
  final prefix = type == DiscountType.fixed ? 'R\$' : '%';
  return AppTextFormFieldFinder(
    name: name,
    type: TextInputType.number,
    prefix: prefix,
    value: null,
  );
}

Finder getEmptyValueFinder(DiscountType? type) {
  final name = type?.label ?? 'Valor';
  final prefix =
      type == null ? null : (type == DiscountType.fixed ? 'R\$' : '%');
  return AppTextFormFieldFinder(
    name: name,
    type: TextInputType.number,
    prefix: prefix,
  );
}

Future<void> inputDiscountInfo(WidgetTester tester, Discount discount) async {
  await tester.enterText(reasonFinder, discount.reason);
  await tester.pump();
  await tester.tap(typeSelectorFinder);
  await tester.pump();
  await tester.tap(find.text(discount.type.label).hitTestable());
  await tester.pump();
  await tester.tap(getValueFinder(discount.type));
  await tester.enterText(
    getValueFinder(discount.type),
    discount.value.toString(),
  );
  await tester.tap(find.byType(PrimaryButton).last);
  await tester.pumpAndSettle();
}

void expectDiscountFormState({
  String? reason,
  DiscountType? type,
  double? value,
}) {
  expect(
    AppTextFormFieldFinder(name: 'Motivo', value: reason ?? ''),
    findsOneWidget,
  );
  expect(
    find.byWidgetPredicate((widget) =>
        widget is AppDropdownButtonField<DiscountType> && widget.value == type),
    findsOneWidget,
  );
  final valueName = type?.label ?? 'Valor';
  final valuePrefix =
      type == null ? null : (type == DiscountType.fixed ? 'R\$' : '%');
  expect(
    AppTextFormFieldFinder(
      name: valueName,
      type: TextInputType.number,
      prefix: valuePrefix,
      value: value != null ? Formatter.simpleNumber(value) : '',
    ),
    findsOneWidget,
  );
}

void expectOrderProductFormState({
  String? name,
  double? quantity,
  MeasurementUnit? measurementUnit,
}) {
  if (quantity != null) {
    expect(
        AppTextFormFieldFinder(
          name: measurementUnit?.label ?? 'Quantidade',
          type: TextInputType.number,
          value: Formatter.simpleNumber(quantity),
        ),
        findsOneWidget);
  }
  if (name != null) {
    expect(
      find.byWidgetPredicate((widget) =>
          widget is SearchTextField<RecipeIngredientSelectorItem> &&
          widget.value?.name == name),
      findsOneWidget,
    );
  }
}

Future<void> inputOrderProductInfo(
  WidgetTester tester,
  String? name,
  double quantity, {
  MeasurementUnit? measurementUnit,
}) async {
  if (name != null) {
    await tester.tap(find.byType(RecipeIngredientSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }
  await tester.enterText(
    AppTextFormFieldFinder(
      name: measurementUnit?.label ?? 'Quantidade',
      type: TextInputType.number,
      value: null,
    ),
    Formatter.simpleNumber(quantity),
  );
  await tester.tap(find.byType(PrimaryButton).last);
  await tester.pumpAndSettle();
}

final clientNameFinder = SearchTextFieldFinder(name: 'Cliente');
final clientContactFinder = AppTextFormFieldFinder(name: 'Contato');
final clientAddressFinder = AppTextFormFieldFinder(name: 'Endereço');
final orderDateFinder = AppDateTimeFieldFinder(name: 'Data do pedido');
final deliveryDateFinder = AppDateTimeFieldFinder(name: 'Data de entrega');
final statusFinder =
    find.byWidgetPredicate((widget) => widget is DropdownButton<OrderStatus>);

expectGeneralOrderInformationFormState({
  SelectedClient? client,
  String? clientContact,
  String? clientAddress,
  OrderStatus? status,
  DateTime? orderDate,
  DateTime? deliveryDate,
}) {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  if (client != null) {
    expect(
      SearchTextFieldFinder(name: 'Cliente', value: client),
      findsOneWidget,
    );
  }
  if (clientContact != null) {
    expect(
      AppTextFormFieldFinder(name: 'Contato', value: clientContact),
      findsOneWidget,
    );
  }
  if (clientAddress != null) {
    expect(
      AppTextFormFieldFinder(name: 'Endereço', value: clientAddress),
      findsOneWidget,
    );
  }
  if (status != null) {
    expect(
      find.byWidgetPredicate((widget) =>
          widget is DropdownButton<OrderStatus> && widget.value == status),
      findsOneWidget,
    );
  }
  if (orderDate != null) {
    expect(AppDateTimeFieldFinder(name: 'Data do pedido'), findsOneWidget);
    expect(find.text(dateFormat.format(orderDate)), findsOneWidget);
  }
  if (deliveryDate != null) {
    expect(AppDateTimeFieldFinder(name: 'Data de entrega'), findsOneWidget);
    expect(find.text(dateFormat.format(deliveryDate)), findsOneWidget);
  }
}

Future<void> inputGeneralOrderInfo(
  WidgetTester tester, {
  String? clientName,
  String? clientContact,
  String? clientAddress,
  OrderStatus? status,
  DateTime? orderDate,
  DateTime? deliveryDate,
}) async {
  if (clientName != null) {
    await tester.tap(clientNameFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(clientName));
    await tester.pumpAndSettle();
  }
  if (clientContact != null) {
    await tester.enterText(clientContactFinder, clientContact);
  }
  if (clientAddress != null) {
    await tester.enterText(clientAddressFinder, clientAddress);
  }
  if (status != null) {
    await tester.tap(statusFinder);
    await tester.pump();
    await tester.tap(find.text(status.label).last);
    await tester.pump();
  }
  if (orderDate != null) {
    await inputDate(tester, orderDateFinder, orderDate);
  }
  if (deliveryDate != null) {
    await inputDate(tester, deliveryDateFinder, deliveryDate);
  }
}

Future<void> inputDate(
    WidgetTester tester, Finder finder, DateTime date) async {
  final format = DateFormat('MM/dd/yyyy');
  // Inputs date
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();
  await tester.enterText(
      find.byType(TextField).hitTestable(), format.format(date));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  // Inputs time
  await tester.tap(find.byIcon(Icons.keyboard));
  await tester.pumpAndSettle();
  if (date.hour >= 12) {
    await tester.tap(find.text('PM'));
    await tester.enterText(
      find.byType(TextField).hitTestable().first,
      (date.hour > 12 ? date.hour - 12 : date.hour).toString(),
    );
  } else {
    await tester.tap(find.text('AM'));
    await tester.enterText(
      find.byType(TextField).hitTestable().first,
      date.hour.toString(),
    );
  }
  await tester.enterText(
    find.byType(TextField).hitTestable().last,
    date.minute.toString(),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> delete(WidgetTester tester, Finder finder) async {
  await tester.drag(finder, const Offset(-1000, 0));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.delete));
  await tester.pump();
}

void expectOrderProductListTile(EditingOrderProductDto orderProduct) {
  expect(find.text(orderProduct.name), findsOneWidget);
  expect(find.text(Formatter.currency(orderProduct.price)), findsOneWidget);
  expect(
    find.text(
      '${Formatter.simpleNumber(orderProduct.quantity)} '
      '${orderProduct.measurementUnit.abbreviation}',
    ),
    findsOneWidget,
  );
}

void expectDiscountListTile(Discount discount) {
  expect(find.text(discount.reason), findsOneWidget);
  switch (discount.type) {
    case DiscountType.fixed:
      {
        expect(find.text(Formatter.currency(discount.value)), findsOneWidget);
        break;
      }
    case DiscountType.percentage:
      {
        expect(
          find.text('${Formatter.simpleNumber(discount.value)}%'),
          findsOneWidget,
        );
        break;
      }
  }
}
