import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

void main() {
  testWidgets('SHOULD expand and show flexible', (tester) async {
    const top = Text('top');
    const bottom = Text('bottom');
    const flexible = Text('flexible');
    var builtFlexible = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Expandable(
            top: top,
            flexibleBuilder: (_) {
              builtFlexible = true;
              return flexible;
            },
            bottom: bottom,
          ),
        ),
      ),
    );

    expect(find.byWidget(top), findsOneWidget);
    expect(find.byWidget(bottom), findsOneWidget);
    expect(find.byWidget(flexible), findsNothing);
    expect(builtFlexible, false);

    // Expands
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.byWidget(top), findsOneWidget);
    expect(find.byWidget(bottom), findsOneWidget);
    expect(find.byWidget(flexible), findsOneWidget);
    expect(builtFlexible, true);

    // Retracts
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.byWidget(top), findsOneWidget);
    expect(find.byWidget(bottom), findsOneWidget);
    expect(find.byWidget(flexible), findsNothing);
  });
}
