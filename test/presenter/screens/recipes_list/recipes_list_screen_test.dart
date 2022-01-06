import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/recipes_list/recipes_list_bloc.dart';
import 'package:kitchen_helper/presenter/screens/recipes_list/widgets/recipe_list_tile.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../../finders.dart';

void main() {
  late RecipesListBloc bloc;
  late StreamController<ScreenState<List<Recipe>>> streamController;

  setUp(() {
    streamController = StreamController();
    bloc = RecipesListBlocMock();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  testWidgets('WHEN in LoadingState SHOULD show loader', (tester) async {
    when(() => bloc.loadRecipes()).thenAnswer((_) async {
      streamController.sink.add(const LoadingState());
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipesListScreen(bloc: bloc),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('WHEN in SuccessState AND has recipes SHOULD show recipes',
      (tester) async {
    when(() => bloc.loadRecipes()).thenAnswer((_) async {
      streamController.sink
          .add(SuccessState([cakeRecipe, sugarWithEggRecipeWithId]));
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipesListScreen(bloc: bloc),
    ));
    await tester.pump();

    expect(find.byType(RecipeListTile), findsNWidgets(2));
  });

  testWidgets('WHEN in SuccessState AND has no recipes SHOULD show empty',
      (tester) async {
    when(() => bloc.loadRecipes()).thenAnswer((_) async {
      streamController.sink.add(const SuccessState([]));
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipesListScreen(bloc: bloc),
    ));
    await tester.pump();

    expect(EmptyFinder(text: 'Sem receitas'), findsOneWidget);
  });

  testWidgets('WHEN in FailureState SHOULD show error message', (tester) async {
    when(() => bloc.loadRecipes()).thenAnswer((_) async {
      streamController.sink.add(FailureState(FakeFailure('failure on load')));
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipesListScreen(bloc: bloc),
    ));
    await tester.pump();

    expect(
        EmptyFinder(text: 'Erro', subtext: 'failure on load'), findsOneWidget);
  });

  Future<void> delete(
    WidgetTester tester,
    Recipe recipe, {
    required Either<Failure, void> result,
  }) async {
    final deleteIconFinder = find.byIcon(Icons.delete);
    expect(deleteIconFinder, findsOneWidget);
    when(() => bloc.delete(recipe)).thenAnswer((_) async => result);
    await tester.tap(deleteIconFinder);
    verify(() => bloc.delete(recipe));
  }

  Future<void> retry(WidgetTester tester) async {
    await tester.pump();
    final retryActionFinder = find.text('Tentar novamente');
    await tap(retryActionFinder, tester);
  }

  Future<void> retryDelete(
    WidgetTester tester,
    Recipe recipe, {
    required Either<Failure, void> result,
  }) async {
    when(() => bloc.delete(cakeRecipe)).thenAnswer((_) async => result);
    await retry(tester);
    verify(() => bloc.delete(cakeRecipe));
  }

  Future<void> undoDelete(
    WidgetTester tester,
    Recipe recipe, {
    required Either<Failure, Recipe> result,
  }) async {
    when(() => bloc.save(recipe)).thenAnswer((_) async => result);
    await tester.pumpAndSettle();
    final undoActionFinder = find.text('Desfazer');
    await tap(undoActionFinder, tester);
    verify(() => bloc.save(recipe));
  }

  Future<void> retryUndoDelete(
    WidgetTester tester,
    Recipe recipe, {
    required Either<Failure, Recipe> result,
  }) async {
    when(() => bloc.save(recipe)).thenAnswer((_) async => result);
    await tester.pumpAndSettle();
    await retry(tester);
    verify(() => bloc.save(recipe));
  }

  testWidgets(
    'SHOULD be able to delete and undelete recipe',
    (tester) async {
      when(() => bloc.loadRecipes()).thenAnswer(
          (_) async => streamController.sink.add(SuccessState([cakeRecipe])));

      await tester.pumpWidget(
        MaterialApp(home: RecipesListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.drag(find.byType(RecipeListTile), const Offset(-500, 0));
      await tester.pump();

      await delete(tester, cakeRecipe, result: const Right(null));
      await undoDelete(tester, cakeRecipe, result: Right(cakeRecipe));
    },
  );

  testWidgets(
    'WHEN delete or undelete fail the user SHOULD be able to retry',
    (tester) async {
      when(() => bloc.loadRecipes()).thenAnswer(
          (_) async => streamController.sink.add(SuccessState([cakeRecipe])));

      await tester.pumpWidget(
        MaterialApp(home: RecipesListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.drag(find.byType(RecipeListTile), const Offset(-500, 0));
      await tester.pump();

      await delete(tester, cakeRecipe, result: Left(FakeFailure('error')));
      await retryDelete(tester, cakeRecipe, result: const Right(null));
      await undoDelete(tester, cakeRecipe, result: Left(FakeFailure('error')));
      await retryUndoDelete(tester, cakeRecipe, result: Right(cakeRecipe));
    },
  );

  testWidgets('WHEN tap on addNewRecipe SHOULD go to EditRecipeScreen',
      (tester) async {
    final navigator = mockNavigator();
    when(() => navigator.pushNamed(
          '/edit-recipe',
          arguments: any(named: 'arguments'),
        )).thenAnswer((_) async => false);
    when(() => bloc.loadRecipes()).thenAnswer(
      (_) async => streamController.sink.add(const SuccessState([])),
    );

    await tester.pumpWidget(MaterialApp(home: RecipesListScreen(bloc: bloc)));
    await tester.pump();

    await tap(find.text('Adicionar receita'), tester);
    verify(() => navigator.pushNamed('/edit-recipe', arguments: null));
  });

  testWidgets('WHEN tap on RecipeListTipe SHOULD go to EditRecipeScreen',
      (tester) async {
    final navigator = mockNavigator();
    when(() => navigator.pushNamed(
          '/edit-recipe',
          arguments: any(named: 'arguments'),
        )).thenAnswer((_) async => true);
    when(() => bloc.loadRecipes()).thenAnswer(
      (_) async => streamController.sink.add(SuccessState([cakeRecipe])),
    );

    await tester.pumpWidget(MaterialApp(home: RecipesListScreen(bloc: bloc)));
    await tester.pump();

    await tap(find.byType(RecipeListTile), tester);
    await tester.pumpAndSettle();

    verify(() => navigator.pushNamed('/edit-recipe', arguments: cakeRecipe));
    verify(() => bloc.loadRecipes()).called(2);
  });
}

Future<void> tap(Finder finder, WidgetTester tester) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

class RecipesListBlocMock extends Mock implements RecipesListBloc {}
