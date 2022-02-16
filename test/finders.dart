import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

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
  final String? value;

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
          (value == null || value == (field.controller?.text ?? ''));
    }
    return false;
  }
}

class SearchTextFieldFinder<T> extends MatchFinder {
  final String name;
  final T? value;

  SearchTextFieldFinder({required this.name, this.value});

  @override
  String get description => 'SearchTextField<$T>(name: "$name", value: $value)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is SearchTextField) {
      final widget = candidate.widget as SearchTextField;
      return widget.name == name && widget.value == value;
    }
    return false;
  }
}

class AppDateTimeFieldFinder extends MatchFinder {
  final String name;

  AppDateTimeFieldFinder({required this.name});

  @override
  String get description => 'AppDateTimeField(name: $name)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is AppDateTimeField) {
      final widget = candidate.widget as AppDateTimeField;
      return widget.name == name;
    }
    return false;
  }
}

class CalculatedValueFinder extends MatchFinder {
  final String title;
  final double value;
  final List<CalculationStep>? calculation;

  CalculatedValueFinder({
    required this.title,
    required this.value,
    this.calculation,
  }) : super(skipOffstage: true);

  @override
  String get description => 'CalculatedValue(title: $title, value: $value, '
      'calculation: $calculation)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is CalculatedValue) {
      final widget = candidate.widget as CalculatedValue;
      return widget.title == title &&
          widget.value == value &&
          calculationMatch(widget.calculation);
    }
    return false;
  }

  bool calculationMatch(List<CalculationStep> widgetCalculation) {
    if (calculation == null) {
      return true;
    }
    return const DeepCollectionEquality()
        .equals(calculation!, widgetCalculation);
  }
}

class ToggleableTagFinder extends MatchFinder {
  final String label;
  final bool value;

  ToggleableTagFinder({required this.label, required this.value});

  @override
  String get description => 'ToggleableTag(label: $label, value: $value)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is ToggleableTag) {
      final widget = candidate.widget as ToggleableTag;
      return widget.label == label && widget.value == value;
    }
    return false;
  }
}

class TagFinder extends MatchFinder {
  final String label;

  TagFinder({required this.label});

  @override
  String get description => 'Tag(label: $label)';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is Tag) {
      final widget = candidate.widget as Tag;
      return widget.label == label;
    }
    return false;
  }
}
