import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  testWidgets('Should render default AppTextFormField correctly',
      (tester) async {
    await pumpWidget(const AppTextFormField(name: 'Test field'), tester);

    verifyTextFormField();
    verifyTextField();
    verifyDecoration();
    verifyLabel(data: 'Test field');
  });
  testWidgets('Should render customized AppTextFormField correctly',
      (tester) async {
    final controller = TextEditingController();
    await pumpWidget(
        AppTextFormField(
          name: 'Test field',
          keyboardType: TextInputType.emailAddress,
          example: 'Example value',
          prefixText: 'Prefix',
          required: false,
          controller: controller,
        ),
        tester);

    verifyTextFormField(validator: null);
    verifyTextField(type: TextInputType.emailAddress, controller: controller);
    verifyDecoration(prefixText: 'Prefix', hintText: 'Ex.: Example value');
    verifyLabel(data: 'Test field');
  });

  testWidgets('Should render default number AppTextFormField correctly',
      (tester) async {
    await pumpWidget(
        const AppTextFormField.number(name: 'Number field'), tester);

    verifyTextFormField();
    verifyTextField(type: TextInputType.number);
    verifyDecoration(hintText: 'Ex.: 10');
    verifyLabel(data: 'Number field');
  });

  testWidgets('Should render default money AppTextFormField correctly',
      (tester) async {
    await pumpWidget(const AppTextFormField.money(name: 'Money field'), tester);

    verifyTextFormField();
    verifyTextField(type: TextInputType.number);
    verifyDecoration(hintText: 'Ex.: 9.90', prefixText: 'R\$');
    verifyLabel(data: 'Money field');
  });
}

Future<void> pumpWidget(AppTextFormField field, WidgetTester tester) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: field,
    ),
  ));
}

void verifyTextFormField({
  String? Function(String?)? validator = Validator.required,
}) {
  final textFormField = getTextFormField();
  expect(textFormField.validator, validator);
  expect(textFormField.autovalidateMode, AutovalidateMode.onUserInteraction);
}

void verifyTextField({
  TextInputType type = TextInputType.text,
  TextEditingController? controller,
}) {
  final textField = getTextField();
  expect(textField.keyboardType, type);
  if (controller != null) {
    expect(textField.controller, controller);
  }
}

void verifyDecoration({String? prefixText, String? hintText}) {
  final decoration = getDecoration();
  expect(decoration!.prefixText, prefixText);
  expect(decoration.hintText, hintText);
}

void verifyLabel({String? data}) {
  final label = getLabel();
  expect(label!.data, data);
}

TextField getTextField() {
  final textFieldMatcher = find.byType(TextField);
  expect(textFieldMatcher, findsOneWidget);
  final textField = textFieldMatcher.evaluate().first.widget as TextField;
  return textField;
}

TextFormField getTextFormField() {
  final textFormFieldMatcher = find.byType(TextFormField);
  expect(textFormFieldMatcher, findsOneWidget);
  final textFormField =
      textFormFieldMatcher.evaluate().first.widget as TextFormField;
  return textFormField;
}

InputDecoration? getDecoration() {
  return getTextField().decoration;
}

Text? getLabel() {
  final decoration = getDecoration();
  expect(decoration!.label, isA<Text?>());
  return decoration.label as Text?;
}
