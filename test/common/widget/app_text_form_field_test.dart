import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

void main() {
  testWidgets('SHOULD render default AppTextFormField correctly',
      (tester) async {
    await pumpWidget(const AppTextFormField(name: 'Test field'), tester);

    verifyTextFormField();
    verifyTextField();
    verifyDecoration();
    verifyLabel(data: 'Test field');
  });
  testWidgets('SHOULD render customized AppTextFormField correctly',
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

  testWidgets('SHOULD render default number AppTextFormField correctly',
      (tester) async {
    await pumpWidget(AppTextFormField.number(name: 'Number field'), tester);

    verifyTextFormField();
    verifyTextField(type: TextInputType.number);
    verifyDecoration(hintText: 'Ex.: 10');
    verifyLabel(data: 'Number field');
  });

  testWidgets('SHOULD render default money AppTextFormField correctly',
      (tester) async {
    await pumpWidget(AppTextFormField.money(name: 'Money field'), tester);

    verifyTextFormField();
    verifyTextField(type: TextInputType.number);
    verifyDecoration(hintText: 'Ex.: 9.90', prefixText: 'R\$');
    verifyLabel(data: 'Money field');
  });

  testWidgets('WHEN initialValue is informed SHOULD render it in text field',
      (tester) async {
    await pumpWidget(
        const AppTextFormField(
          name: 'Text with value',
          initialValue: 'initial value',
        ),
        tester);

    verifyTextFormField(value: 'initial value');
  });

  testWidgets('WHEN initialValue is informed SHOULD render it in number field',
      (tester) async {
    await pumpWidget(
        AppTextFormField.number(
          name: 'Number with value',
          initialValue: 10,
        ),
        tester);

    verifyTextFormField(value: '10');
  });

  testWidgets('WHEN initialValue is informed SHOULD render it in money field',
      (tester) async {
    await pumpWidget(
        AppTextFormField.money(
          name: 'Text with value',
          initialValue: 7.5,
        ),
        tester);

    verifyTextFormField(value: '7.50');
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
  String? value,
}) {
  final textFormField = getTextFormField();
  expect(textFormField.validator, validator);
  expect(textFormField.autovalidateMode, AutovalidateMode.onUserInteraction);
  if (value != null) {
    expect(textFormField.controller?.text, value);
  }
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
