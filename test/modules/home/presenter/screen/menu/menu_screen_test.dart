import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/home/presenter/screen/menu/menu_screen.dart';
import 'package:kitchen_helper/modules/home/presenter/screen/menu/widgets/page_description_tile.dart';

void main() {
  testWidgets('Should render PageDescriptionTiles for all main pages',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));

    expect(
      PageDescriptionTileFinder('Ingredientes', '/ingredients'),
      findsOneWidget,
    );
  });
}

class PageDescriptionTileFinder extends MatchFinder {
  final String name;
  final String route;

  PageDescriptionTileFinder(this.name, this.route, {bool skipOffstage = true})
      : super(skipOffstage: skipOffstage);

  @override
  String get description => 'PageDescriptionTile(name: $name)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is PageDescriptionTile) {
      final tile = candidate.widget as PageDescriptionTile;
      return tile.name == name && tile.route == route;
    }
    return false;
  }
}
