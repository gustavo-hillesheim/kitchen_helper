import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/widgets/recipe_ingredient_selector.dart';
import 'package:kitchen_helper/presenter/widgets/recipe_ingredient_selector_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';
import '../finders.dart';

void main() {
  late RecipeIngredientSelectorService service;
  late OnChangedMock onChanged;
  final dropdownFinder = find.byWidgetPredicate(
    (widget) => widget is DropdownSearch<RecipeIngredientSelectorItem>,
  );

  setUp(() {
    onChanged = OnChangedMock();
    service = RecipeIngredientSelectorServiceMock();
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    RecipeIngredientSelectorItem? initialValue,
    RecipeIngredientSelectorItems? showOnly,
    RecipeFilter? recipeFilter,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RecipeIngredientSelector(
          onChanged: onChanged,
          initialValue: initialValue,
          showOnly: showOnly ?? RecipeIngredientSelectorItems.all,
          recipeFilter: recipeFilter,
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
    when(() => service.getItems(getOnly: any(named: 'getOnly')))
        .thenAnswer((_) async => const Right([]));

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
    when(() => service.getItems(getOnly: any(named: 'getOnly'))).thenAnswer(
      (_) async => const Left(FakeFailure('some error')),
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
      initialValue: const RecipeIngredientSelectorItem(
        id: 1,
        name: 'value',
        type: RecipeIngredientType.ingredient,
        measurementUnit: MeasurementUnit.kilograms,
      ),
    );

    expect(find.text('value'), findsOneWidget);
  });

  testWidgets('WHEN user chooses item SHOULD call onChanged', (tester) async {
    final cakeRecipeSelectorItem = RecipeIngredientSelectorItem(
      id: cakeRecipe.id!,
      name: cakeRecipe.name,
      measurementUnit: cakeRecipe.measurementUnit,
      type: RecipeIngredientType.recipe,
    );

    when(() => onChanged(any())).thenReturn(null);
    when(() => service.getItems(getOnly: any(named: 'getOnly'))).thenAnswer(
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

  testWidgets('WHEN getOnly is informed SHOULD call service with it',
      (tester) async {
    when(() => service.getItems(getOnly: any(named: 'getOnly'))).thenAnswer(
      (_) async => const Right([]),
    );
    await pumpWidget(tester, showOnly: RecipeIngredientSelectorItems.recipes);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    verify(
        () => service.getItems(getOnly: RecipeIngredientSelectorItems.recipes));
  });

  testWidgets('WHEN recipeFilter is informed SHOULD call service with it',
      (tester) async {
    const filter = RecipeFilter(canBeSold: true);
    when(() => service.getItems(
        getOnly: any(named: 'getOnly'),
        recipeFilter: any(named: 'recipeFilter'))).thenAnswer(
      (_) async => const Right([]),
    );
    await pumpWidget(tester, recipeFilter: filter);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    verify(() => service.getItems(
          recipeFilter: filter,
          getOnly: RecipeIngredientSelectorItems.all,
        ));
  });
}

class OnChangedMock extends Mock {
  void call(RecipeIngredientSelectorItem? item);
}
