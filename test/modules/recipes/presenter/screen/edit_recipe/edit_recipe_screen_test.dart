import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/edit_recipe_screen.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/widgets/ingredients_list.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../finders.dart';
import '../../../../../mocks.dart';
import 'helpers.dart';

void main() {
  late EditRecipeBloc bloc;
  late StreamController<ScreenState<Recipe>> streamController;
  final nameFieldFinder = AppTextFormFieldFinder(name: 'Nome');
  ScreenState<Recipe> state = const EmptyState();

  void defaultMocks() {
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
    when(() => bloc.state).thenAnswer((_) => state);
    when(() => bloc.loadRecipe(sugarWithEggRecipeWithId.id!))
        .thenAnswer((_) async {
      streamController.sink.add(SuccessState(sugarWithEggRecipeWithId));
    });
    when(() => bloc.getEditingRecipeIngredient(any())).thenAnswer(
      (invocation) async {
        final ingredient = invocation.positionalArguments[0];
        return Right(EditingRecipeIngredient.fromModels(
          ingredient,
          ingredient: ingredientsMap[ingredient.id],
        ));
      },
    );
  }

  setUp(() {
    streamController = StreamController.broadcast();
    bloc = EditRecipeBlocMock();
    registerFallbackValue(FakeRecipe());
    registerFallbackValue(const RecipeIngredient(
      id: 1,
      type: RecipeIngredientType.ingredient,
      quantity: 1,
    ));
    mockRecipeIngredientsSelectorService();
    streamController.stream.listen((newState) => state = newState);
    defaultMocks();
  });

  Future<void> fillRecipeInformation(WidgetTester tester) async {
    await tester.enterText(nameFieldFinder, 'Cake');

    await fillGeneralInformationForm(
      tester,
      quantityProduced: 5,
      quantitySold: 1,
      price: 15,
      notes: 'Notes and notes',
      canBeSold: true,
      measurementUnit: MeasurementUnit.units,
    );

    // Fills ingredients
    await tester.tap(find.text('Ingredientes'));
    await tester.pumpAndSettle();
    await addIngredient(tester, quantity: 12, ingredientName: egg.name);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'WHEN recipe is saved with success SHOULD pop page with true result',
    (tester) async {
      final navigator = mockNavigator();
      when(() => bloc.save(any()))
          .thenAnswer((_) async => const SuccessState(null));
      when(() => navigator.pop(any())).thenAnswer((_) {});

      await tester.pumpWidget(MaterialApp(home: EditRecipeScreen(bloc: bloc)));

      expect(find.text('Nova receita'), findsOneWidget);
      await fillRecipeInformation(tester);

      await tester.tap(find.text('Salvar'));

      verify(
        () => bloc.save(Recipe(
          name: 'Cake',
          quantityProduced: 5,
          notes: 'Notes and notes',
          quantitySold: 1,
          price: 15,
          canBeSold: true,
          measurementUnit: MeasurementUnit.units,
          ingredients: [
            RecipeIngredient.ingredient(egg.id!, quantity: 12),
          ],
        )),
      );
      // Navigator pops with result to reload recipes list
      verify(() => navigator.pop(true));
    },
  );

  testWidgets(
    'WHEN recipe is saved with failure SHOULD show snackbar message',
    (tester) async {
      when(() => bloc.save(any()))
          .thenAnswer((_) async => const FailureState(FakeFailure('error')));

      await tester.pumpWidget(MaterialApp(home: EditRecipeScreen(bloc: bloc)));

      expect(find.text('Nova receita'), findsOneWidget);
      await fillRecipeInformation(tester);

      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('error'), findsOneWidget);
    },
  );

  testWidgets('WHEN has initialValue SHOULD render fields with value',
      (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const FailureState(FakeFailure('error')));
    when(() => bloc.getCost(any())).thenAnswer((_) async => const Right(10));
    when(() => bloc.getEditingRecipeIngredients(any())).thenAnswer(
      (_) async => Right(editingRecipeIngredients(sugarWithEggRecipeWithId)),
    );

    await tester.pumpWidget(MaterialApp(
        home: EditRecipeScreen(
      bloc: bloc,
      id: sugarWithEggRecipeWithId.id!,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Editar receita'), findsOneWidget);
    expect(
      AppTextFormFieldFinder(
        name: 'Quantidade produzida',
        type: TextInputType.number,
        value:
            Formatter.simpleNumber(sugarWithEggRecipeWithId.quantityProduced),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MeasurementUnitSelector &&
            widget.value == sugarWithEggRecipeWithId.measurementUnit,
        description: 'MeasurementUnitSelector',
      ),
      findsOneWidget,
    );
    expect(
      AppTextFormFieldFinder(
          name: 'Anotações', value: sugarWithEggRecipeWithId.notes ?? ''),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.value == sugarWithEggRecipeWithId.canBeSold,
        description: 'CanBeSoldListTile',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Ingredientes'));
    await tester.pumpAndSettle();
    for (final recipeIngredient in sugarWithEggRecipeWithId.ingredients) {
      final ingredient = ingredientsMap[recipeIngredient.id]!;
      expect(find.text(ingredient.name), findsOneWidget);
      expect(
        find.text(
          '${Formatter.simpleNumber(recipeIngredient.quantity)} '
          '${ingredient.measurementUnit.abbreviation}',
        ),
        findsOneWidget,
      );
      final cost =
          ingredient.cost / ingredient.quantity * recipeIngredient.quantity;
      expect(find.text(Formatter.currency(cost)), findsOneWidget);
    }
  });

  testWidgets('SHOULD be able to edit and delete ingredients', (tester) async {
    when(() => bloc.save(any()))
        .thenAnswer((_) async => const FailureState(FakeFailure('error')));
    when(() => bloc.getCost(any())).thenAnswer((_) async => const Right(10));
    when(() => bloc.getEditingRecipeIngredients(any())).thenAnswer(
      (invocation) async =>
          Right(editingRecipeIngredients(invocation.positionalArguments[0])),
    );

    await tester.pumpWidget(MaterialApp(
        home: EditRecipeScreen(
      bloc: bloc,
      id: sugarWithEggRecipeWithId.id!,
    )));

    await tester.tap(find.text('Ingredientes'));
    await tester.pumpAndSettle();

    final ingredientFinder = find.byType(IngredientListTile);
    expect(ingredientFinder, findsNWidgets(2));
    // Removes one ingredient
    await tester.drag(ingredientFinder.first, const Offset(-100, 0));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(ingredientFinder, findsOneWidget);

    await tester.tap(ingredientFinder);
    await tester.pump();
    final ingredient =
        ingredientsMap[sugarWithEggRecipeWithId.ingredients[1].id]!;
    await tester.enterText(
      AppTextFormFieldFinder(
        name: ingredient.measurementUnit.label,
        type: TextInputType.number,
        value: Formatter.simpleNumber(ingredient.quantity),
      ),
      '10',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar').last);
    await tester.pumpAndSettle();

    expect(
      find.text('10 ${ingredient.measurementUnit.abbreviation}'),
      findsOneWidget,
    );
  });
}
