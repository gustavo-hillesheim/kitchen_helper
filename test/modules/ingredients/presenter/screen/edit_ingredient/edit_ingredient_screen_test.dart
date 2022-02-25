import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/ingredients/presenter/screen/edit_ingredient/edit_ingredient_bloc.dart';
import 'package:kitchen_helper/modules/ingredients/presenter/screen/edit_ingredient/edit_ingredient_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../finders.dart';
import '../../../../../mocks.dart';

void main() {
  final emptyNameFieldFinder = AppTextFormFieldFinder(name: 'Nome');
  final emptyQuantityFieldFinder =
      AppTextFormFieldFinder(name: 'Quantidade', type: TextInputType.number);
  final emptyCostFieldFinder = AppTextFormFieldFinder(
      name: 'Custo', type: TextInputType.number, prefix: 'R\$');
  late EditIngredientBloc bloc;
  late StreamController<ScreenState<Ingredient>> streamController;
  ScreenState<Ingredient> state = const EmptyState();

  setUp(() {
    bloc = EditIngredientBlocMock();
    streamController = StreamController.broadcast();
    streamController.stream.listen((newState) => state = newState);
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
    when(() => bloc.state).thenAnswer((_) => state);
  });

  testWidgets(
    'Should render fields and save button correctly',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: EditIngredientScreen(bloc: bloc)),
      );

      expect(emptyNameFieldFinder, findsOneWidget);
      expect(emptyQuantityFieldFinder, findsOneWidget);
      expect(emptyCostFieldFinder, findsOneWidget);
      expect(find.byType(MeasurementUnitSelector), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
    },
  );

  testWidgets(
    'Should render fields with initial value correctly',
    (tester) async {
      when(() => bloc.loadIngredient(egg.id!)).thenAnswer(
          (_) async => streamController.sink.add(const SuccessState(egg)));
      await tester.pumpWidget(
        MaterialApp(
            home: EditIngredientScreen(
          bloc: bloc,
          id: egg.id!,
        )),
      );
      await tester.pumpAndSettle();

      expect(
        AppTextFormFieldFinder(name: 'Nome', value: egg.name),
        findsOneWidget,
      );
      expect(
        AppTextFormFieldFinder(
          name: 'Quantidade',
          type: TextInputType.number,
          value: Formatter.simpleNumber(egg.quantity),
        ),
        findsOneWidget,
      );
      expect(
        AppTextFormFieldFinder(
          name: 'Custo',
          type: TextInputType.number,
          prefix: 'R\$',
          value: egg.cost.toStringAsFixed(2),
        ),
        findsOneWidget,
      );
      expect(
        MeasurementUnitSelectorFinder(value: egg.measurementUnit),
        findsOneWidget,
      );
    },
  );

  testWidgets('Should not call bloc.save if input values are invalid',
      (tester) async {
    when(() => bloc.loadIngredient(egg.id!)).thenAnswer(
        (_) async => streamController.sink.add(const SuccessState(egg)));
    registerFallbackValue(egg);

    await tester
        .pumpWidget(MaterialApp(home: EditIngredientScreen(bloc: bloc)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.save(any()));
  });

  testWidgets('Should call bloc.save if input values are valid',
      (tester) async {
    const expectedIngredient = Ingredient(
      name: 'egg',
      quantity: 12,
      measurementUnit: MeasurementUnit.units,
      cost: 10.5,
    );
    when(() => bloc.save(expectedIngredient))
        .thenAnswer((_) async => const Right(null));
    await tester
        .pumpWidget(MaterialApp(home: EditIngredientScreen(bloc: bloc)));

    await tester.enterText(emptyNameFieldFinder, 'egg');
    await tester.enterText(emptyQuantityFieldFinder, '12');
    await tester.enterText(emptyCostFieldFinder, '10.50');
    await tester.tap(find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<MeasurementUnit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(MeasurementUnit.units.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(() => bloc.save(expectedIngredient));
  });

  testWidgets('Should exit screen if save is successful', (tester) async {
    final navigator = mockNavigator();
    when(() => bloc.loadIngredient(egg.id!)).thenAnswer(
        (_) async => streamController.sink.add(const SuccessState(egg)));
    when(() => bloc.save(egg)).thenAnswer((_) async => const Right(null));

    await tester.pumpWidget(MaterialApp(
        home: EditIngredientScreen(
      bloc: bloc,
      id: egg.id,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(() => bloc.save(egg));
    verify(() => navigator.pop(true));
  });

  testWidgets('Should show error text if save fails', (tester) async {
    final navigator = mockNavigator();
    when(() => bloc.loadIngredient(egg.id!)).thenAnswer(
        (_) async => streamController.sink.add(const SuccessState(egg)));
    when(() => bloc.save(egg))
        .thenAnswer((_) async => Left(FakeFailure('Error text')));

    await tester.pumpWidget(MaterialApp(
        home: EditIngredientScreen(
      bloc: bloc,
      id: egg.id,
    )));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Salvar'));
    await tester.pump();

    verify(() => bloc.save(egg));
    verifyNever(() => navigator.pop(any()));
    expect(find.text('Error text'), findsOneWidget);
  });

  test('Should navigate to ingredients route', () async {
    final navigator = mockNavigator();

    when(() => navigator.pushNamed(any(), arguments: any(named: 'arguments')))
        .thenAnswer((_) async => false);

    EditIngredientScreen.navigate(egg.id);

    verify(() => navigator.pushNamed('./edit', arguments: egg.id));
  });
}

class EditIngredientBlocMock extends Mock implements EditIngredientBloc {}

class MeasurementUnitSelectorFinder extends MatchFinder {
  final MeasurementUnit? value;

  MeasurementUnitSelectorFinder({
    this.value,
    bool skipOffstage = true,
  }) : super(skipOffstage: skipOffstage);

  @override
  String get description => 'MeasurementUnitSelector(value: $value)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is MeasurementUnitSelector) {
      final field = candidate.widget as MeasurementUnitSelector;
      return field.value == value;
    }
    return false;
  }
}
