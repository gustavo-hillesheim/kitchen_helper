import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  testWidgets('Should render child widget', (tester) async {
    final theme = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const BottomCard(child: Text('Inside the bottom card')),
      ),
    );

    expect(find.text('Inside the bottom card'), findsOneWidget);
    expect(
      ContainerByColorFinder(theme.scaffoldBackgroundColor),
      findsOneWidget,
    );
  });
}

class ContainerByColorFinder extends MatchFinder {
  final Color color;

  ContainerByColorFinder(this.color, {bool skipOffstage = true})
      : super(skipOffstage: skipOffstage);

  @override
  String get description => 'Container(color: $color)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is Container) {
      final containerWidget = candidate.widget as Container;
      if (containerWidget.decoration is BoxDecoration) {
        final decoration = containerWidget.decoration as BoxDecoration;
        return decoration.color?.value == color.value;
      }
      return containerWidget.color?.value == color.value;
    }
    return false;
  }
}
