import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_order/edit_order_bloc.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import 'helpers.dart';

void main() {
  late EditOrderBloc bloc;
  late SaveOrderUseCase saveOrderUseCase;
  late GetRecipeUseCase getRecipeUseCase;
  late GetRecipeCostUseCase getRecipeCostUseCase;
  late GetOrderUseCase getOrderUseCase;

  setUp(() {
    registerFallbackValue(FakeOrder());
    saveOrderUseCase = SaveOrderUseCaseMock();
    getRecipeUseCase = GetRecipeUseCaseMock();
    getRecipeCostUseCase = GetRecipeCostUseCaseMock();
    getOrderUseCase = GetOrderUseCaseMock();
    bloc = EditOrderBloc(
      saveOrderUseCase,
      getRecipeUseCase,
      getRecipeCostUseCase,
      getOrderUseCase,
    );
  });

  test('SHOULD start with EmptyState', () {
    expect(bloc.state, const EmptyState<Order>());
  });

  blocTest<EditOrderBloc, ScreenState<Order>>(
    'WHEN saves SHOULD call saveOrderUseCase',
    setUp: () {
      when(() => saveOrderUseCase.execute(any()))
          .thenAnswer((_) async => Right(spidermanOrderWithId));
    },
    build: () => bloc,
    act: (bloc) => bloc.save(spidermanOrder),
    expect: () => <ScreenState<Order>>[
      const LoadingState(),
      SuccessState(spidermanOrderWithId),
    ],
  );

  blocTest<EditOrderBloc, ScreenState<Order>>(
    'WHEN saveOrderUseCase fails SHOULD return FailureState',
    setUp: () {
      when(() => saveOrderUseCase.execute(any()))
          .thenAnswer((_) async => const Left(FakeFailure('failure')));
    },
    build: () => bloc,
    act: (bloc) => bloc.save(spidermanOrder),
    expect: () => <ScreenState<Order>>[
      const LoadingState(),
      const FailureState(FakeFailure('failure')),
    ],
  );

  test(
      'WHEN getEditingOrderProducts is called SHOULD return list of EditingOrderProduct',
      () async {
    when(() => getRecipeUseCase.execute(cakeRecipe.id!))
        .thenAnswer((_) async => Right(cakeRecipe));
    when(() => getRecipeUseCase.execute(iceCreamRecipe.id!))
        .thenAnswer((_) async => Right(iceCreamRecipe));
    when(() => getRecipeCostUseCase.execute(cakeRecipe))
        .thenAnswer((_) async => Right(cakeRecipe.id!.toDouble()));
    when(() => getRecipeCostUseCase.execute(iceCreamRecipe))
        .thenAnswer((_) async => Right(iceCreamRecipe.id!.toDouble()));

    final result = await bloc.getEditingOrderProducts(
      [cakeOrderProduct, iceCreamOrderProduct],
    );

    expect(
      result.getRight().toNullable(),
      editingOrderProducts([cakeOrderProduct, iceCreamOrderProduct]),
    );
    verify(() => getRecipeUseCase.execute(cakeRecipe.id!));
    verify(() => getRecipeUseCase.execute(iceCreamRecipe.id!));
    verify(() => getRecipeCostUseCase.execute(cakeRecipe));
    verify(() => getRecipeCostUseCase.execute(iceCreamRecipe));
  });

  test('WHEN getRecipeUseCase fails SHOULD return Failure', () async {
    when(() => getRecipeUseCase.execute(cakeRecipe.id!))
        .thenAnswer((_) async => Right(cakeRecipe));
    when(() => getRecipeUseCase.execute(iceCreamRecipe.id!)).thenAnswer(
        (_) async => const Left(FakeFailure('can not get ice cream')));
    when(() => getRecipeCostUseCase.execute(cakeRecipe))
        .thenAnswer((_) async => const Right(50));

    final result = await bloc.getEditingOrderProducts(
      [cakeOrderProduct, iceCreamOrderProduct],
    );

    expect(result.getLeft().toNullable()?.message, 'can not get ice cream');
    verify(() => getRecipeUseCase.execute(cakeRecipe.id!));
    verify(() => getRecipeUseCase.execute(iceCreamRecipe.id!));
    verify(() => getRecipeCostUseCase.execute(cakeRecipe));
    verifyNever(() => getRecipeCostUseCase.execute(iceCreamRecipe));
  });

  test('WHEN getRecipeCostUseCase fails SHOULD return Failure', () async {
    when(() => getRecipeUseCase.execute(cakeRecipe.id!))
        .thenAnswer((_) async => Right(cakeRecipe));
    when(() => getRecipeCostUseCase.execute(cakeRecipe))
        .thenAnswer((_) async => const Left(FakeFailure('can not get cost')));

    final result = await bloc.getEditingOrderProducts(
      [cakeOrderProduct],
    );

    expect(result.getLeft().toNullable()?.message, 'can not get cost');
    verify(() => getRecipeUseCase.execute(cakeRecipe.id!));
    verify(() => getRecipeCostUseCase.execute(cakeRecipe));
  });
}
