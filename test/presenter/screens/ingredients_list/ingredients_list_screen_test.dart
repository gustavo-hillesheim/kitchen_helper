import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/ingredients_list_bloc.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/ingredients_list_screen.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/widgets/ingredient_list_tile.dart';
import 'package:kitchen_helper/presenter/widgets/empty.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late IngredientsListBloc bloc;
  late StreamController<IngredientListState> streamController;

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
    when(() => bloc.loadIngredients())
        .thenAnswer((_) async => streamController.sink.add(LoadingState()));

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
        (_) async => streamController.sink.add(SuccessState(const [])));

    await tester.pumpWidget(
      MaterialApp(home: IngredientsListScreen(bloc: bloc)),
    );
    await tester.pump();

    expect(find.byType(Empty), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));

    verify(() => navigator.pushNamed('/edit-ingredient', arguments: null));
  });

  testWidgets('Should show Empty with error message if there is a Failure',
      (tester) async {
    when(() => bloc.loadIngredients()).thenAnswer((_) async =>
        streamController.sink.add(FailureState(FakeFailure('fake error'))));

    await tester.pumpWidget(
      MaterialApp(home: IngredientsListScreen(bloc: bloc)),
    );
    await tester.pump();

    expect(EmptyFinder(text: 'Erro', subtext: 'fake error'), findsOneWidget);
  });

  testWidgets('Should show Ingredient list', (tester) async {
    when(() => bloc.loadIngredients()).thenAnswer(
        (_) async => streamController.sink.add(SuccessState(ingredientList)));

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
      when(() => navigator.pushNamed(any(), arguments: egg))
          .thenAnswer((_) async => false);
      when(() => bloc.loadIngredients()).thenAnswer(
          (_) async => streamController.sink.add(SuccessState([egg])));

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.tap(find.byType(IngredientListTile));

      verify(() => navigator.pushNamed('/edit-ingredient', arguments: egg));
    },
  );

  testWidgets(
    'Should be able to delete and undelete ingredient',
    (tester) async {
      when(() => bloc.delete(egg)).thenAnswer((_) async => const Right(null));
      when(() => bloc.save(egg)).thenAnswer((_) async => Right(egg));
      when(() => bloc.loadIngredients()).thenAnswer(
          (_) async => streamController.sink.add(SuccessState([egg])));

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.drag(find.byType(IngredientListTile), const Offset(-500, 0));
      await tester.pump();

      final deleteIconFinder = find.byIcon(Icons.delete);
      expect(deleteIconFinder, findsOneWidget);

      await tester.tap(deleteIconFinder);
      verify(() => bloc.delete(egg));

      await tester.pump();
      final undoActionFinder = find.text('Desfazer');
      await tap(undoActionFinder, tester);

      verify(() => bloc.save(egg));
    },
  );

  testWidgets(
    'If delete or undelete fail the user should be able to retry',
    (tester) async {
      when(() => bloc.loadIngredients()).thenAnswer(
          (_) async => streamController.sink.add(SuccessState([egg])));

      await tester.pumpWidget(
        MaterialApp(home: IngredientsListScreen(bloc: bloc)),
      );
      await tester.pump();

      await tester.drag(find.byType(IngredientListTile), const Offset(-500, 0));
      await tester.pump();

      final deleteIconFinder = find.byIcon(Icons.delete);
      expect(deleteIconFinder, findsOneWidget);

      when(() => bloc.delete(egg))
          .thenAnswer((_) async => Left(FakeFailure('error')));
      await tester.tap(deleteIconFinder);
      verify(() => bloc.delete(egg));

      when(() => bloc.delete(egg)).thenAnswer((_) async => const Right(null));
      await tester.pump();
      final retryActionFinder = find.text('Tentar novamente');
      await tap(retryActionFinder, tester);
      verify(() => bloc.delete(egg));

      when(() => bloc.save(egg))
          .thenAnswer((_) async => Left(FakeFailure('error')));
      await tester.pumpAndSettle();
      final undoActionFinder = find.text('Desfazer');
      await tap(undoActionFinder, tester);
      verify(() => bloc.save(egg));

      when(() => bloc.save(egg)).thenAnswer((_) async => Right(egg));
      await tester.pumpAndSettle();
      await tap(retryActionFinder, tester);
      verify(() => bloc.save(egg));
    },
  );
}

Future<void> tap(Finder finder, WidgetTester tester) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

class EmptyFinder extends MatchFinder {
  final String text;
  final String subtext;

  EmptyFinder({
    required this.text,
    required this.subtext,
    bool skipOffstage = true,
  }) : super(skipOffstage: skipOffstage);

  @override
  String get description => 'Empty(text: $text, subtext: $subtext)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is Empty) {
      final empty = candidate.widget as Empty;
      return empty.text == text && empty.subtext == subtext;
    }
    return false;
  }
}

class IngredientsListBlocMock extends Mock implements IngredientsListBloc {}
