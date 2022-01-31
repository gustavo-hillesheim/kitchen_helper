import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

import 'tag_test.dart';

void main() {
  testWidgets('WHEN tapped SHOULD change color', (tester) async {
    var calledOnChange = false;
    final widget = ToggleableTag(
      label: 'Test',
      onChange: (_) => calledOnChange = true,
      activeColor: Colors.blue,
      inactiveColor: Colors.red,
    );
    await tester.pumpWidget(MaterialApp(home: widget));

    expectTag(
      label: 'Test',
      backgroundColor: Colors.red,
      foregroundColor: Colors.blue,
    );

    await tester.tap(find.byWidget(widget));
    await tester.pump();

    expectTag(
      label: 'Test',
      backgroundColor: Colors.blue,
      foregroundColor: Colors.red,
    );
    expect(calledOnChange, true);
  });

  testWidgets('WHEN colors are not informed SHOULD use from theme',
      (tester) async {
    final widget = ToggleableTag(
      label: 'Test',
      onChange: (_) {},
      activeColor: Colors.blue,
      inactiveColor: Colors.red,
    );
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: widget,
    ));

    expectTag(
      label: 'Test',
      backgroundColor: Colors.red,
      foregroundColor: Colors.blue,
    );
  });

  testWidgets(
      'WHEN value is informed SHOULD use it instead of internal '
      'value', (tester) async {
    var calledOnChange = false;
    final widget = ToggleableTag(
      label: 'Test',
      value: false,
      onChange: (_) => calledOnChange = true,
      activeColor: Colors.blue,
      inactiveColor: Colors.red,
    );
    await tester.pumpWidget(MaterialApp(home: widget));

    expectTag(
      label: 'Test',
      backgroundColor: Colors.red,
      foregroundColor: Colors.blue,
    );

    await tester.tap(find.byWidget(widget));
    await tester.pump();

    // Should not change
    expectTag(
      label: 'Test',
      backgroundColor: Colors.red,
      foregroundColor: Colors.blue,
    );
    expect(calledOnChange, true);
  });
}
