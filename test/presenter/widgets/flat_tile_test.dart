import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  testWidgets('SHOULD render child and onTap', (tester) async {
    const child = Text('some text');
    var tapped = false;
    void onTap() => tapped = true;

    await tester.pumpWidget(MaterialApp(
      home: FlatTile(
        child: child,
        onTap: onTap,
      ),
    ));

    expect(find.byWidget(child), findsOneWidget);
    expect(tapped, false);
    await tester.tap(find.byWidget(child));
    expect(tapped, true);
  });
}
