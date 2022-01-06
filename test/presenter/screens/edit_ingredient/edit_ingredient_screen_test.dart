import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/edit_ingredient/edit_ingredient_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../../finders.dart';

void main() {
  final emptyNameFieldFinder = AppTextFormFieldFinder(name: 'Nome');
  final emptyQuantityFieldFinder =
      AppTextFormFieldFinder(name: 'Quantidade', type: TextInputType.number);
  final emptyCostFieldFinder = AppTextFormFieldFinder(
      name: 'Custo', type: TextInputType.number, prefix: 'R\$');
  late EditIngredientBloc bloc;
  late StreamController<EditIngredientState> streamController;

  setUp(() {
    bloc = EditIngredientBlocMock();
    streamController = StreamController();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
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
      await tester.pumpWidget(
        MaterialApp(
            home: EditIngredientScreen(
          bloc: bloc,
          initialValue: egg,
        )),
      );

      expect(
        AppTextFormFieldFinder(name: 'Nome', value: egg.name),
        findsOneWidget,
      );
      expect(
        AppTextFormFieldFinder(
          name: 'Quantidade',
          type: TextInputType.number,
          value: Formatter.simple(egg.quantity),
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

  testWidgets('Save button SHOULD update according to State', (tester) async {
    void verifyButtonIsEnabled() {
      expect(
          find.byWidgetPredicate(
              (widget) => widget is ElevatedButton && widget.enabled),
          findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }

    void verifyButtonIsLoading() {
      expect(
          find.byWidgetPredicate(
              (widget) => widget is ElevatedButton && !widget.enabled),
          findsOneWidget);
      expect(find.text('Salvar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }

    await tester
        .pumpWidget(MaterialApp(home: EditIngredientScreen(bloc: bloc)));

    verifyButtonIsEnabled();

    streamController.sink.add(LoadingState());
    await tester.pump();

    verifyButtonIsLoading();

    streamController.sink.add(SuccessState(egg));
    await tester.pump();

    verifyButtonIsEnabled();
  });

  testWidgets('Should not call bloc.save if input values are invalid',
      (tester) async {
    registerFallbackValue(egg);

    await tester
        .pumpWidget(MaterialApp(home: EditIngredientScreen(bloc: bloc)));

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.save(any()));
  });

  testWidgets('Should call bloc.save if input values are valid',
      (tester) async {
    final expectedIngredient = const Ingredient(
      name: 'egg',
      quantity: 12,
      measurementUnit: MeasurementUnit.units,
      cost: 10.5,
    );
    when(() => bloc.save(expectedIngredient))
        .thenAnswer((_) async => SuccessState(egg));
    await tester
        .pumpWidget(MaterialApp(home: EditIngredientScreen(bloc: bloc)));

    await tester.enterText(emptyNameFieldFinder, 'egg');
    await tester.enterText(emptyQuantityFieldFinder, '12');
    await tester.enterText(emptyCostFieldFinder, '10.50');
    await tester.tap(find.byType(MeasurementUnitSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text(MeasurementUnit.units.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(() => bloc.save(expectedIngredient));
  });

  testWidgets('Should exit screen if save is successful', (tester) async {
    final navigator = mockNavigator();
    when(() => bloc.save(egg)).thenAnswer((_) async => SuccessState(egg));

    await tester.pumpWidget(MaterialApp(
        home: EditIngredientScreen(
      bloc: bloc,
      initialValue: egg,
    )));

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(() => bloc.save(egg));
    verify(() => navigator.pop(true));
  });

  testWidgets('Should show error text if save fails', (tester) async {
    final navigator = mockNavigator();
    when(() => bloc.save(egg))
        .thenAnswer((_) async => FailureState(FakeFailure('Error text')));

    await tester.pumpWidget(MaterialApp(
        home: EditIngredientScreen(
      bloc: bloc,
      initialValue: egg,
    )));

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Error text'), findsOneWidget);
    verify(() => bloc.save(egg));
    verifyNever(() => navigator.pop(any()));
  });

  test('Should navigate to ingredients route', () async {
    final navigator = mockNavigator();

    when(() => navigator.pushNamed(any(), arguments: any(named: 'arguments')))
        .thenAnswer((_) async => false);

    EditIngredientScreen.navigate(egg);

    verify(() => navigator.pushNamed('/edit-ingredient', arguments: egg));
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
