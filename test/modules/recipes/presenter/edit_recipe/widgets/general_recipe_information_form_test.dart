import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/modules/recipes/presenter/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/modules/recipes/presenter/edit_recipe/widgets/general_recipe_information_form.dart';

import '../../../../../mocks.dart';
import '../../../../../presenter/finders.dart';
import '../helpers.dart';

void main() {
  late EditRecipeBloc bloc;

  setUp(() {
    bloc = EditRecipeBlocMock();
  });

  testWidgets('SHOULD render text fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeneralRecipeInformationForm(
            quantityProducedController: TextEditingController(),
            notesController: TextEditingController(),
            quantitySoldController: TextEditingController(),
            priceController: TextEditingController(),
            canBeSoldNotifier: ValueNotifier(false),
            measurementUnitNotifier: ValueNotifier(null),
            cost: 10,
            bloc: bloc,
          ),
        ),
      ),
    );

    expect(quantityProducedFieldFinder, findsOneWidget);
    expect(measurementUnitSelectorFinder, findsOneWidget);
    expect(notesFieldFinder, findsOneWidget);
    expect(canBeSoldFieldFinder, findsOneWidget);
    expect(quantitySoldFieldFinder, findsNothing);
    expect(priceFieldFinder, findsNothing);
    expect(
      find.text(GeneralRecipeInformationForm.unableToCalculateProfitText),
      findsNothing,
    );

    // Shows quantity sold and price fields
    await tester.tap(canBeSoldFieldFinder);
    await tester.pumpAndSettle();

    expect(quantitySoldFieldFinder, findsOneWidget);
    expect(priceFieldFinder, findsOneWidget);
    expect(
      find.text(GeneralRecipeInformationForm.unableToCalculateProfitText),
      findsOneWidget,
    );
  });

  testWidgets('WHEN quantities and price are informed SHOULD show profit info',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeneralRecipeInformationForm(
            quantityProducedController: TextEditingController(),
            notesController: TextEditingController(),
            quantitySoldController: TextEditingController(),
            priceController: TextEditingController(),
            // needs to be true to show quantity sold and price fields
            canBeSoldNotifier: ValueNotifier(false),
            measurementUnitNotifier: ValueNotifier(null),
            cost: 10,
            bloc: bloc,
          ),
        ),
      ),
    );

    await fillGeneralInformationForm(
      tester,
      quantityProduced: 100,
      quantitySold: 10,
      price: 10,
      canBeSold: true,
      measurementUnit: MeasurementUnit.units,
    );
    await tester.pump();

    expect(
      CalculatedValueFinder(
        title: 'Lucro por 10 ${MeasurementUnit.units.label}',
        value: 9,
      ),
      findsOneWidget,
    );
  });

  testWidgets('WHEN values are informed SHOULD update controllers',
      (tester) async {
    final quantityProducedController = TextEditingController();
    final notesController = TextEditingController();
    final quantitySoldController = TextEditingController();
    final priceController = TextEditingController();
    final canBeSoldNotifier = ValueNotifier(false);
    final measurementUnitNotifier = ValueNotifier<MeasurementUnit?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeneralRecipeInformationForm(
            quantityProducedController: quantityProducedController,
            notesController: notesController,
            quantitySoldController: quantitySoldController,
            priceController: priceController,
            // needs to be true to show quantity sold and price fields
            canBeSoldNotifier: canBeSoldNotifier,
            measurementUnitNotifier: measurementUnitNotifier,
            cost: 10,
            bloc: bloc,
          ),
        ),
      ),
    );

    await fillGeneralInformationForm(
      tester,
      quantityProduced: 100,
      quantitySold: 10,
      price: 5,
      canBeSold: true,
      notes: 'Some notes',
      measurementUnit: MeasurementUnit.units,
    );

    expect(quantityProducedController.text, '100');
    expect(notesController.text, 'Some notes');
    expect(quantitySoldController.text, '10');
    expect(priceController.text, '5');
    expect(canBeSoldNotifier.value, true);
    expect(measurementUnitNotifier.value, MeasurementUnit.units);
  });
}
