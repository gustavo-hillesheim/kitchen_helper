import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

class EmptyFinder extends MatchFinder {
  final String text;
  final String? subtext;

  EmptyFinder({
    required this.text,
    this.subtext,
    bool skipOffstage = true,
  }) : super(skipOffstage: skipOffstage);

  @override
  String get description => 'Empty(text: $text, subtext: $subtext)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is Empty) {
      final empty = candidate.widget as Empty;
      return empty.text == text &&
          (empty.subtext == subtext || subtext == null);
    }
    return false;
  }
}
