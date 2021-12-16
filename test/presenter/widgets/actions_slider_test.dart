import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  testWidgets(
      'WHEN onDelete is informed '
      'SHOULD be able to slide widget to delete', (tester) async {
    const child = SizedBox(height: 50, width: double.infinity);
    var tapped = false;
    void onDelete() => tapped = true;

    await tester.pumpWidget(MaterialApp(
      home: ActionsSlider(child: child, onDelete: onDelete),
    ));

    expect(find.byWidget(child), findsOneWidget);

    await tester.drag(
      find.byWidget(child),
      const Offset(-500, 0),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(tapped, false);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete));
    expect(tapped, true);
  });

  testWidgets(
      'WHEN onDelete is not informed '
      'SHOULD not be able to slide to delete', (tester) async {
    const child = SizedBox(height: 50, width: double.infinity);

    await tester.pumpWidget(const MaterialApp(
      home: ActionsSlider(child: child),
    ));

    expect(find.byWidget(child), findsOneWidget);

    await tester.drag(
      find.byWidget(child),
      const Offset(-500, 0),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete), findsNothing);
  });
}
