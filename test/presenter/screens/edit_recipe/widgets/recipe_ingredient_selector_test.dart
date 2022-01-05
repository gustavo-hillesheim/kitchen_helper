import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/recipe_ingredient_selector.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/recipe_ingredient_selector_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';
import '../../../finders.dart';

void main() {
  late RecipeIngredientSelectorService service;
  late OnChangedMock onChanged;
  final dropdownFinder = find.byWidgetPredicate(
    (widget) => widget is DropdownSearch<SelectorItem>,
  );

  setUp(() {
    onChanged = OnChangedMock();
    service = RecipeIngredientSelectorServiceMock();
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    EditingRecipeIngredient? initialValue,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RecipeIngredientSelector(
          onChanged: onChanged,
          initialValue: initialValue,
          service: service,
        ),
      ),
    ));
  }

  testWidgets('SHOULD render DropdownSearch', (tester) async {
    await pumpWidget(tester);

    expect(dropdownFinder, findsOneWidget);
  });

  testWidgets('WHEN there are no items SHOULD render Empty state',
      (tester) async {
    when(() => service.getItems()).thenAnswer((_) async => const Right([]));

    await pumpWidget(tester);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    expect(
      EmptyFinder(
        text: RecipeIngredientSelector.emptyText,
        subtext: RecipeIngredientSelector.emptySubtext,
      ),
      findsOneWidget,
    );
  });

  testWidgets('WHEN service returns Failure SHOULD render Error state',
      (tester) async {
    when(() => service.getItems()).thenAnswer(
      (_) async => Left(FakeFailure('some error')),
    );

    await pumpWidget(tester);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    expect(
      EmptyFinder(
        text: RecipeIngredientSelector.errorText,
        subtext: RecipeIngredientSelector.errorSubtext,
      ),
      findsOneWidget,
    );
  });

  testWidgets('WHEN initialValue is informed SHOULD render initial value',
      (tester) async {
    await pumpWidget(
      tester,
      initialValue: const EditingRecipeIngredient(
        id: 1,
        name: 'value',
        type: RecipeIngredientType.ingredient,
        measurementUnit: MeasurementUnit.kilograms,
        quantity: 1,
        cost: 1,
      ),
    );

    expect(find.text('value'), findsOneWidget);
  });

  testWidgets('WHEN user chooses item SHOULD call onChanged', (tester) async {
    final cakeRecipeSelectorItem = SelectorItem(
      id: cakeRecipe.id!,
      name: cakeRecipe.name,
      measurementUnit: cakeRecipe.measurementUnit,
      type: RecipeIngredientType.recipe,
    );

    when(() => onChanged(any())).thenReturn(null);
    when(() => service.getItems()).thenAnswer(
      (_) async => Right([cakeRecipeSelectorItem]),
    );

    await pumpWidget(tester);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final cakeRecipeFinder = find.text(cakeRecipe.name);
    expect(cakeRecipeFinder, findsOneWidget);

    await tester.tap(cakeRecipeFinder);

    verify(() => onChanged(cakeRecipeSelectorItem));
  });
}

class OnChangedMock extends Mock {
  void call(SelectorItem? item);
}
