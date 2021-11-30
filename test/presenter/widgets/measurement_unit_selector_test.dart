import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/presenter/utils/validator.dart';
import 'package:kitchen_helper/presenter/widgets/measurement_unit_selector.dart';

void main() {
  testWidgets('Should render default MeasurementUnitSelector correctly',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Material(
        child: MeasurementUnitSelector(onChange: onChange),
      ),
    ));

    verifyDropdownButtonFormField();
    verifyDropdownButton();
  });

  testWidgets('Should render customized MeasurementUnitSelector correctly',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Material(
      child: MeasurementUnitSelector(
        onChange: onChange,
        required: false,
        value: MeasurementUnit.units,
      ),
    )));

    verifyDropdownButtonFormField(validator: null);
    verifyDropdownButton(value: MeasurementUnit.units);
  });
}

void onChange(_) {}

void verifyDropdownButtonFormField({
  String? Function(String?)? validator = Validator.required,
}) {
  final dropdownField = getDropdownButtonFormField();
  expect(dropdownField.onChanged, onChange);
  expect(dropdownField.autovalidateMode, AutovalidateMode.onUserInteraction);
  expect(dropdownField.validator, validator);
}

void verifyDropdownButton({MeasurementUnit? value}) {
  final dropdown = getDropdownButton();
  expect(dropdown.value, value);
  final seenMeasurementUnits = <MeasurementUnit>{};
  expect(dropdown.items!.length, MeasurementUnit.values.length);
  for (var item in dropdown.items!) {
    verifyDropdownButtonItem(item, seenMeasurementUnits);
  }
  expect(seenMeasurementUnits.length, MeasurementUnit.values.length);
}

void verifyDropdownButtonItem(
  DropdownMenuItem<MeasurementUnit> item,
  Set<MeasurementUnit> seenMeasurementUnits,
) {
  expect(item.value, isNotNull);
  seenMeasurementUnits.add(item.value!);
  expect(item.child, isA<Text>());
  expect((item.child as Text).data, item.value!.label);
}

DropdownButtonFormField<MeasurementUnit> getDropdownButtonFormField() {
  final dropdownFieldFinder =
      find.byWidgetPredicate((widget) => widget is DropdownButtonFormField);
  expect(dropdownFieldFinder, findsOneWidget);
  final dropdownField = dropdownFieldFinder.evaluate().first.widget
      as DropdownButtonFormField<MeasurementUnit>;
  return dropdownField;
}

DropdownButton<MeasurementUnit> getDropdownButton() {
  final dropdownFinder =
      find.byWidgetPredicate((widget) => widget is DropdownButton);
  expect(dropdownFinder, findsOneWidget);
  final dropdown =
      dropdownFinder.evaluate().first.widget as DropdownButton<MeasurementUnit>;
  return dropdown;
}

Text? getLabel() {
  final label = getDropdownButtonFormField().decoration.label;
  expect(label, isA<Text?>());
  return label as Text?;
}
