import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../common.dart';

typedef SearchFn<T> = Future<List<T>> Function(String? search);
typedef GetLabelFn<T> = String Function(T? value);

class SearchTextField<T> extends StatelessWidget {
  static const defaultEmptyTitle = 'Nenhum registro encontrado';
  static const defaultEmptySubtext = '';
  static const defaultErrorTitle = 'Erro';
  static const defaultErrorSubtext = 'Não foi possível listar os registros';
  static String defaultGetLabel(item) => item?.toString() ?? '';

  final String name;
  final ValueChanged<T?> onChanged;
  final T? initialValue;
  final SearchFn<T> onSearch;
  final GetLabelFn<T> getLabelFromValue;
  final bool required;
  final String emptyTitle;
  final String emptySubtext;
  final String errorTitle;
  final String errorSubtext;

  const SearchTextField({
    Key? key,
    required this.name,
    required this.onChanged,
    required this.onSearch,
    this.required = true,
    GetLabelFn<T>? getLabelFromValue,
    this.emptyTitle = defaultEmptyTitle,
    this.emptySubtext = defaultEmptySubtext,
    this.errorTitle = defaultErrorTitle,
    this.errorSubtext = defaultErrorSubtext,
    this.initialValue,
  })  : getLabelFromValue = getLabelFromValue ?? defaultGetLabel,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      selectedItem: initialValue,
      showSearchBox: true,
      onFind: onSearch,
      dropdownSearchDecoration: InputDecoration(
          labelText: name,
          contentPadding: const EdgeInsets.fromLTRB(11, 11, 0, 0)),
      validator: required ? Validator.required : null,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      filterFn: _filterFn,
      itemAsString: (item) => getLabelFromValue(item),
      dropdownBuilderSupportsNullItem: false,
      dropdownBuilder: (_, item) => Text(getLabelFromValue(item)),
      loadingBuilder: _loadingBuilder,
      emptyBuilder: _emptyBuilder,
      errorBuilder: _errorBuilder,
      onChanged: onChanged,
    );
  }

  bool _filterFn(T? item, String? search) {
    if (item == null) {
      return false;
    }
    if (search == null) {
      return true;
    }
    return getLabelFromValue(item)
        .toLowerCase()
        .startsWith(search.toLowerCase());
  }

  Widget _loadingBuilder(_, __) => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _emptyBuilder(_, __) => Center(
        child: Empty(text: emptyTitle, subtext: emptySubtext),
      );

  Widget _errorBuilder(_, __, error) {
    if (error is Error) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
    return Center(
      child: Empty(
        text: errorTitle,
        subtext: errorSubtext,
        icon: Icons.error_outline_outlined,
      ),
    );
  }
}
