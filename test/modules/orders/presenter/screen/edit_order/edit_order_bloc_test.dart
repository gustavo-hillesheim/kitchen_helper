import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/edit_order_bloc.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';

void main() {
  late EditOrderBloc bloc;
  late SaveEditingOrderDtoUseCaseMock saveOrderUseCase;
  late GetEditingOrderDtoUseCaseMock getOrderUseCase;
  late GetRecipeUseCase getRecipeUseCase;
  late GetRecipeCostUseCase getRecipeCostUseCase;
  late GetContactsDomainUseCase getContactsDomainUseCase;
  late GetAddressDomainUseCase getAddressDomainUseCase;

  setUp(() {
    registerFallbackValue(FakeOrder());
    registerFallbackValue(FakeEditingOrderDto());
    saveOrderUseCase = SaveEditingOrderDtoUseCaseMock();
    getRecipeUseCase = GetRecipeUseCaseMock();
    getRecipeCostUseCase = GetRecipeCostUseCaseMock();
    getOrderUseCase = GetEditingOrderDtoUseCaseMock();
    getContactsDomainUseCase = GetContactsDomainUseCaseMock();
    getAddressDomainUseCase = GetAddressDomainUseCaseMock();
    bloc = EditOrderBloc(
      saveOrderUseCase,
      getRecipeUseCase,
      getRecipeCostUseCase,
      getOrderUseCase,
      getContactsDomainUseCase,
      getAddressDomainUseCase,
    );
  });

  test('SHOULD start with EmptyState', () {
    expect(bloc.state, const EmptyState<void>());
  });

  blocTest<EditOrderBloc, ScreenState<void>>(
    'WHEN saves SHOULD call saveOrderUseCase',
    setUp: () {
      when(() => saveOrderUseCase.execute(any()))
          .thenAnswer((_) async => Right(spidermanOrderWithId));
    },
    build: () => bloc,
    act: (bloc) => bloc.save(editingSpidermanOrderDtoWithId),
    expect: () => <ScreenState<void>>[
      const LoadingState(),
      const SuccessState(null),
    ],
  );

  blocTest<EditOrderBloc, ScreenState<void>>(
    'WHEN saveOrderUseCase fails SHOULD return FailureState',
    setUp: () {
      when(() => saveOrderUseCase.execute(any()))
          .thenAnswer((_) async => Left(FakeFailure('failure')));
    },
    build: () => bloc,
    act: (bloc) => bloc.save(editingSpidermanOrderDtoWithId),
    expect: () => <ScreenState<void>>[
      const LoadingState(),
      FailureState(FakeFailure('failure')),
    ],
  );

  test('WHEN getRecipeUseCase fails SHOULD return Failure', () async {
    when(() => getRecipeUseCase.execute(iceCreamRecipe.id!))
        .thenAnswer((_) async => Left(FakeFailure('can not get ice cream')));

    final result = await bloc.getEditingOrderProduct(iceCreamOrderProduct);

    expect(result.getLeft().toNullable()?.message, 'can not get ice cream');
    verify(() => getRecipeUseCase.execute(iceCreamRecipe.id!));
    verifyNever(() => getRecipeCostUseCase.execute(iceCreamRecipe));
  });

  test('WHEN getRecipeCostUseCase fails SHOULD return Failure', () async {
    when(() => getRecipeUseCase.execute(cakeRecipe.id!))
        .thenAnswer((_) async => Right(cakeRecipe));
    when(() => getRecipeCostUseCase.execute(cakeRecipe))
        .thenAnswer((_) async => Left(FakeFailure('can not get cost')));

    final result = await bloc.getEditingOrderProduct(cakeOrderProduct);

    expect(result.getLeft().toNullable()?.message, 'can not get cost');
    verify(() => getRecipeUseCase.execute(cakeRecipe.id!));
    verify(() => getRecipeCostUseCase.execute(cakeRecipe));
  });
}
