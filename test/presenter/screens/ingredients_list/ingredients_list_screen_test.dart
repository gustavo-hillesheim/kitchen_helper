import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/ingredients_list_bloc.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/widgets/ingredient_list_tile.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../../finders.dart';

void main() {
  late IngredientsListBloc bloc;
  late StreamController<ScreenState<List<ListingIngredientDto>>>
      streamController;

  setUp(() {
    bloc = IngredientsListBlocMock();
    streamController = StreamController();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  testWidgets(
    'Should navigate to EditIngredientScreen on tap on add button',
    (tester) async {
      final navigator = mockNavigator();
      when(() => navigator.pushNamed('/edit-ingredient'))
          .thenAnswer((_) async => false);
      when(() => bloc.loadIngredients()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );

      await tester.tap(find.text('Adicionar'));

      verify(() => navigator.pushNamed('/edit-ingredient', arguments: null));
    },
  );

  testWidgets(
    'Should reload if EditIngredientScreen returns true',
    (tester) async {
      final navigator = mockNavigator();
      when(() => navigator.pushNamed('/edit-ingredient'))
          .thenAnswer((_) async => true);
      when(() => bloc.loadIngredients()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );

      await tester.tap(find.text('Adicionar'));

      verify(() => navigator.pushNamed('/edit-ingredient', arguments: null));
      verify(() => bloc.loadIngredients()).called(2);
    },
  );

  testWidgets('Should show loader while in LoadingState', (tester) async {
    when(() => bloc.loadIngredients()).thenAnswer(
        (_) async => streamController.sink.add(const LoadingState()));

    await tester.pumpWidget(
      MaterialApp(home: IngredientsListScreen(bloc: bloc)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should show Empty if there are no ingredients', (tester) async {
    final navigator = mockNavigator();
    when(() => navigator.pushNamed('/edit-ingredient'))
        .thenAnswer((_) async => false);
    when(() => bloc.loadIngredients()).thenAnswer(
        (_) async => streamController.sink.add(const SuccessState([])));

    await tester.pumpWidget(
      MaterialApp(home: IngredientsListScreen(bloc: bloc)),
    );
    await tester.pump();

    expect(EmptyFinder(text: 'Sem ingredientes'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));

    verify(() => navigator.pushNamed('/edit-ingredient', arguments: null));
  });

  testWidgets('Should show Empty with error message if there is a Failure',
      (tester) async {
    when(() => bloc.loadIngredients()).thenAnswer((_) async => streamController
        .sink
        .add(const FailureState(FakeFailure('fake error'))));

    await tester.pumpWidget(
      MaterialApp(home: IngredientsListScreen(bloc: bloc)),
    );
    await tester.pump();

    expect(EmptyFinder(text: 'Erro', subtext: 'fake error'), findsOneWidget);
  });

  testWidgets('Should show Ingredient list', (tester) async {
    when(() => bloc.loadIngredients()).thenAnswer((_) async =>
        streamController.sink.add(SuccessState(listingIngredientDtoList)));

    await tester.pumpWidget(
      MaterialApp(home: IngredientsListScreen(bloc: bloc)),
    );
    await tester.pump();

    expect(find.byType(IngredientListTile), findsNWidgets(3));
  });

  testWidgets(
    'Should navigate to EditIngredientScreen when IngredientListTile is tapped',
    (tester) async {
      final navigator = mockNavigator();
      when(() => navigator.pushNamed(any(), arguments: egg.id))
          .thenAnswer((_) async => false);
      when(() => bloc.loadIngredients()).thenAnswer((_) async =>
          streamController.sink.add(const SuccessState([listingEggDto])));

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.tap(find.byType(IngredientListTile));

      verify(() => navigator.pushNamed('/edit-ingredient', arguments: egg.id));
    },
  );

  Future<void> delete(
    WidgetTester tester,
    ListingIngredientDto ingredient, {
    required Either<Failure, Ingredient> result,
  }) async {
    final deleteIconFinder = find.byIcon(Icons.delete);
    expect(deleteIconFinder, findsOneWidget);
    when(() => bloc.delete(ingredient.id)).thenAnswer((_) async => result);
    await tester.tap(deleteIconFinder);
    verify(() => bloc.delete(ingredient.id));
  }

  Future<void> retry(WidgetTester tester) async {
    await tester.pump();
    final retryActionFinder = find.text('Tentar novamente');
    await tap(retryActionFinder, tester);
  }

  Future<void> retryDelete(
    WidgetTester tester,
    ListingIngredientDto ingredient, {
    required Either<Failure, Ingredient> result,
  }) async {
    when(() => bloc.delete(ingredient.id)).thenAnswer((_) async => result);
    await retry(tester);
    verify(() => bloc.delete(ingredient.id));
  }

  Future<void> undoDelete(
    WidgetTester tester,
    Ingredient ingredient, {
    required Either<Failure, Ingredient> result,
  }) async {
    when(() => bloc.save(ingredient)).thenAnswer((_) async => result);
    await tester.pumpAndSettle();
    final undoActionFinder = find.text('Desfazer');
    await tap(undoActionFinder, tester);
    verify(() => bloc.save(ingredient));
  }

  Future<void> retryUndoDelete(
    WidgetTester tester,
    Ingredient ingredient, {
    required Either<Failure, Ingredient> result,
  }) async {
    when(() => bloc.save(ingredient)).thenAnswer((_) async => result);
    await tester.pumpAndSettle();
    await retry(tester);
    verify(() => bloc.save(ingredient));
  }

  testWidgets(
    'Should be able to delete and undelete ingredient',
    (tester) async {
      when(() => bloc.loadIngredients()).thenAnswer((_) async =>
          streamController.sink.add(const SuccessState([listingEggDto])));

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.drag(find.byType(IngredientListTile), const Offset(-500, 0));
      await tester.pump();

      await delete(tester, listingEggDto, result: const Right(egg));
      await undoDelete(tester, egg, result: const Right(egg));
    },
  );

  testWidgets(
    'If delete or undelete fail the user should be able to retry',
    (tester) async {
      when(() => bloc.loadIngredients()).thenAnswer((_) async =>
          streamController.sink.add(const SuccessState([listingEggDto])));

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.drag(find.byType(IngredientListTile), const Offset(-500, 0));
      await tester.pump();

      await delete(tester, listingEggDto,
          result: const Left(FakeFailure('error')));
      await retryDelete(tester, listingEggDto, result: const Right(egg));
      await undoDelete(tester, egg, result: const Left(FakeFailure('error')));
      await retryUndoDelete(tester, egg, result: const Right(egg));
    },
  );
}

Future<void> tap(Finder finder, WidgetTester tester) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

class IngredientsListBlocMock extends Mock implements IngredientsListBloc {}
