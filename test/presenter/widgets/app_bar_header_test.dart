import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  testWidgets('Should render default AppBarPageHeader correctly',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          final header = createHeader(context);
          return header.builder(context, header.maxHeight);
        },
      ),
    ));

    expect(find.text('Header'), findsOneWidget);
    verifyAction();
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('Should render AppBarPageHeader inside ModalRoute correctly',
      (tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      home: TextButton(
        onPressed: () => key.currentState!.push(
          MaterialPageRoute(
            builder: (context) {
              final header = createHeader(context);
              return Material(child: header.builder(context, header.minHeight));
            },
          ),
        ),
        child: const SizedBox(),
      ),
    ));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Header'), findsOneWidget);
    verifyAction();
    expect(find.byType(BackButton), findsOneWidget);
  });
}

void onActionPressed() {}

AppBarHeader createHeader(BuildContext context) {
  return AppBarHeader(
    title: 'Header',
    context: context,
    action: AppBarHeaderAction(
      label: 'Action',
      icon: Icons.delete,
      onPressed: onActionPressed,
    ),
  );
}

void verifyAction() {
  final actionMatcher =
      find.byWidgetPredicate((widget) => widget is TextButton);
  expect(actionMatcher, findsOneWidget);
  final action = actionMatcher.evaluate().first.widget as TextButton;
  expect(action.onPressed, onActionPressed);
  expect(find.text('Action'), findsOneWidget);
  expect(find.byIcon(Icons.delete), findsOneWidget);
}
