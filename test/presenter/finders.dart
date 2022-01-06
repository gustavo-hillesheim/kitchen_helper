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

class AppTextFormFieldFinder extends MatchFinder {
  final String name;
  final TextInputType? type;
  final String? prefix;
  final String value;

  AppTextFormFieldFinder({
    required this.name,
    this.type,
    this.prefix,
    this.value = '',
    bool skipOffstage = true,
  }) : super(skipOffstage: skipOffstage);

  @override
  String get description => 'AppTextFormField(name: $name, type: $type, '
      'prefix: $prefix, value: $value)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is AppTextFormField) {
      final field = candidate.widget as AppTextFormField;
      return field.name == name &&
          field.keyboardType == type &&
          field.prefixText == prefix &&
          field.controller?.text == value;
    }
    return false;
  }
}
