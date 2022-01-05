import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/general_information_form.dart';
import 'package:mocktail/mocktail.dart';

import '../../../finders.dart';

void main() {
  late EditRecipeBloc bloc;
  final quantityProducedFieldFinder = AppTextFormFieldFinder(
    name: 'Quantidade produzida',
    type: TextInputType.number,
  );
  final measurementUnitSelectorFinder = find.byType(MeasurementUnitSelector);
  final notesFieldFinder = AppTextFormFieldFinder(name: 'Anotações');
  final canBeSoldFieldFinder = find.byType(CheckboxListTile);
  final quantitySoldFieldFinder = AppTextFormFieldFinder(
    name: 'Quantidade vendida',
    type: TextInputType.number,
  );
  final priceFieldFinder = AppTextFormFieldFinder(
    name: 'Preço de venda',
    type: TextInputType.number,
    prefix: 'R\$',
  );

  setUp(() {
    bloc = EditRecipeBlocMock();
  });

  testWidgets('SHOULD render text fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeneralInformationForm(
            quantityProducedController: TextEditingController(),
            notesController: TextEditingController(),
            quantitySoldController: TextEditingController(),
            priceController: TextEditingController(),
            canBeSoldNotifier: ValueNotifier(false),
            measurementUnitNotifier: ValueNotifier(null),
            cost: 10,
            bloc: bloc,
            initialValue: null,
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
      find.text(GeneralInformationForm.unableToCalculateProfitText),
      findsNothing,
    );

    // Shows quantity sold and price fields
    await tester.tap(canBeSoldFieldFinder);
    await tester.pumpAndSettle();

    expect(quantitySoldFieldFinder, findsOneWidget);
    expect(priceFieldFinder, findsOneWidget);
    expect(
      find.text(GeneralInformationForm.unableToCalculateProfitText),
      findsOneWidget,
    );
  });

  testWidgets('WHEN quantities and price are informed SHOULD show profit info',
      (tester) async {
    when(() => bloc.calculateProfitPerQuantitySold(
          quantityProduced: any(named: 'quantityProduced'),
          quantitySold: any(named: 'quantitySold'),
          pricePerQuantitySold: any(named: 'pricePerQuantitySold'),
          totalCost: any(named: 'totalCost'),
        )).thenAnswer((_) => 9);
    when(() => bloc.calculateTotalProfit(
          quantityProduced: any(named: 'quantityProduced'),
          quantitySold: any(named: 'quantitySold'),
          pricePerQuantitySold: any(named: 'pricePerQuantitySold'),
          totalCost: any(named: 'totalCost'),
        )).thenAnswer((_) => 90);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeneralInformationForm(
            quantityProducedController: TextEditingController(),
            notesController: TextEditingController(),
            quantitySoldController: TextEditingController(),
            priceController: TextEditingController(),
            // needs to be true to show quantity sold and price fields
            canBeSoldNotifier: ValueNotifier(true),
            measurementUnitNotifier: ValueNotifier(null),
            cost: 10,
            bloc: bloc,
            initialValue: null,
          ),
        ),
      ),
    );

    // Selects measurement unit
    await tester.tap(measurementUnitSelectorFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(MeasurementUnit.units.label).last);
    await tester.pumpAndSettle();
    // Fills production and selling information
    await tester.enterText(quantityProducedFieldFinder, '100');
    await tester.enterText(quantitySoldFieldFinder, '10');
    await tester.enterText(priceFieldFinder, '10');
    await tester.pump();

    expect(
      find.text('Lucro por 10 ${MeasurementUnit.units.label}: R\$9.00'),
      findsOneWidget,
    );
    expect(find.text('Lucro total: R\$90.00'), findsOneWidget);
  });

  testWidgets('WHEN values are informed SHOULD update controllers',
      (tester) async {
    when(() => bloc.calculateProfitPerQuantitySold(
          quantityProduced: any(named: 'quantityProduced'),
          quantitySold: any(named: 'quantitySold'),
          pricePerQuantitySold: any(named: 'pricePerQuantitySold'),
          totalCost: any(named: 'totalCost'),
        )).thenAnswer((_) => 9);
    when(() => bloc.calculateTotalProfit(
          quantityProduced: any(named: 'quantityProduced'),
          quantitySold: any(named: 'quantitySold'),
          pricePerQuantitySold: any(named: 'pricePerQuantitySold'),
          totalCost: any(named: 'totalCost'),
        )).thenAnswer((_) => 90);

    final quantityProducedController = TextEditingController();
    final notesController = TextEditingController();
    final quantitySoldController = TextEditingController();
    final priceController = TextEditingController();
    final canBeSoldNotifier = ValueNotifier(false);
    final measurementUnitNotifier = ValueNotifier<MeasurementUnit?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeneralInformationForm(
            quantityProducedController: quantityProducedController,
            notesController: notesController,
            quantitySoldController: quantitySoldController,
            priceController: priceController,
            // needs to be true to show quantity sold and price fields
            canBeSoldNotifier: canBeSoldNotifier,
            measurementUnitNotifier: measurementUnitNotifier,
            cost: 10,
            bloc: bloc,
            initialValue: null,
          ),
        ),
      ),
    );

    await tester.tap(canBeSoldFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterText(quantityProducedFieldFinder, '100');
    await tester.enterText(notesFieldFinder, 'Some notes');
    await tester.enterText(quantitySoldFieldFinder, '10');
    await tester.enterText(priceFieldFinder, '5');
    // Selects measurement unit
    await tester.tap(measurementUnitSelectorFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(MeasurementUnit.units.label).last);
    await tester.pumpAndSettle();

    expect(quantityProducedController.text, '100');
    expect(notesController.text, 'Some notes');
    expect(quantitySoldController.text, '10');
    expect(priceController.text, '5');
    expect(canBeSoldNotifier.value, true);
    expect(measurementUnitNotifier.value, MeasurementUnit.units);
  });
}

class EditRecipeBlocMock extends Mock implements EditRecipeBloc {}
