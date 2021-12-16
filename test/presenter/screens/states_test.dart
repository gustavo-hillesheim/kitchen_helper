import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';

import '../../mocks.dart';

void main() {
  group('runEither', () {
    blocTest(
      'WHEN either returns Left SHOULD emit FailureState',
      build: () => TestCubit(),
      expect: () => <ScreenState<String>>[
        const LoadingState(),
        FailureState(FakeFailure('error')),
      ],
      act: (TestCubit bloc) {
        bloc.runEither(() async => Left(FakeFailure('error')));
      },
    );
    blocTest(
      'WHEN either returns Right SHOULD emit SuccessState',
      build: () => TestCubit(),
      expect: () => const <ScreenState<String>>[
        LoadingState(),
        SuccessState('success string'),
      ],
      act: (TestCubit bloc) {
        bloc.runEither(() async => const Right('success string'));
      },
    );
  });
}

class TestCubit extends AppCubit<String> {
  TestCubit() : super(const LoadingState());
}
