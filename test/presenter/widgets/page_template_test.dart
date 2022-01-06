import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

const minHeight = 100.0;
const maxHeight = 200.0;
const headerKey = ValueKey('header');
const bodyKey = ValueKey('body');

void main() {
  testWidgets('Should render PageTemplate correctly', (tester) async {
    await pumpWidget(tester);

    final scrollController = getScrollController();
    verifyHeader(height: maxHeight);
    verifyBody(scrollController, scroll: 0);

    final swipeGesture = await tester.startGesture(const Offset(0, 300));
    await swipeGesture.moveBy(const Offset(0, -200));
    await tester.pump();

    verifyHeader(height: minHeight);
    verifyBody(scrollController, scroll: 200);

    // First we need to move to 0 scroll, then move again to expand the header
    await swipeGesture.moveBy(const Offset(0, 200));
    await swipeGesture.moveBy(const Offset(0, 200));
    await tester.pumpAndSettle();

    verifyBody(scrollController, scroll: 0);
    verifyHeader(height: maxHeight);
  });
}

Future<void> pumpWidget(WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(
      home: PageTemplate(
        header: PageHeader(
          minHeight: minHeight,
          maxHeight: maxHeight,
          builder: (_, height) {
            return Container(
              key: headerKey,
              color: Colors.blue,
              height: height,
            );
          },
        ),
        body: SingleChildScrollView(
          key: bodyKey,
          child: Container(
            color: Colors.red,
            height: 10000,
          ),
        ),
      ),
    ),
  );
}

ScrollController getScrollController() {
  final primaryScrollControllerMatcher = find.byType(PrimaryScrollController);
  final scrollController = primaryScrollControllerMatcher
      .evaluate()
      .map((el) => el.widget as PrimaryScrollController)
      .where((widget) => widget.controller is StoppableScrollController)
      .first
      .controller!;
  return scrollController;
}

void verifyHeader({required double height}) {
  final headerMatcher = find.byKey(headerKey);
  expect(headerMatcher, findsOneWidget);
  final header = headerMatcher.evaluate().first.widget as Container;
  expect(header.constraints?.smallest.height, height);
}

void verifyBody(
  ScrollController scrollController, {
  required double scroll,
}) {
  final bodyMatcher = find.byKey(bodyKey);
  expect(bodyMatcher, findsOneWidget);
  expect(scrollController.position.pixels, scroll);
}
