import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

import '../../mocks.dart';

void main() {
  testWidgets('SHOULD render states correctly', (tester) async {
    final streamController = StreamController<ScreenState<String>>();

    await tester.pumpWidget(MaterialApp(
      home: ScreenStateBuilder<String>(
        stateStream: streamController.stream,
        loadingBuilder: (_) => const Text('loading'),
        successBuilder: (_, text) => Text(text),
        errorBuilder: (_, failure) => Text(failure.message),
      ),
    ));

    // If the stream contains no data should use loadingBuilder
    expect(find.text('loading'), findsOneWidget);

    streamController.sink.add(const LoadingState());
    await tester.pumpAndSettle();
    // If the stream contains a LoadingState should use loadingBuilder
    expect(find.text('loading'), findsOneWidget);

    streamController.sink.add(FailureState(FakeFailure('some error')));
    await tester.pumpAndSettle();
    // If the stream constains a Failurestate should use errorBuilder
    expect(find.text('some error'), findsOneWidget);

    streamController.sink.add(const SuccessState('success value'));
    await tester.pumpAndSettle();
    // If the stream contains a SuccessState should use successBuilder
    expect(find.text('success value'), findsOneWidget);
  });

  testWidgets(
      'WHEN no loadingBuilder is informed SHOULD display the default one',
      (tester) async {
    final streamController = StreamController<ScreenState<String>>();

    await tester.pumpWidget(MaterialApp(
      home: ScreenStateBuilder<String>(
        stateStream: streamController.stream,
        successBuilder: (_, text) => Text(text),
        errorBuilder: (_, failure) => Text(failure.message),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
