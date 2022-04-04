import 'package:flutter/material.dart';

import '../common.dart';

typedef SearchFn<T> = Future<List<T>> Function(String? search);
typedef GetLabelFn<T> = String Function(T? value);
typedef FilterFn<T> = List<T> Function(List<T> items, String? search);

class SearchTextField<T> extends StatelessWidget {
  static const defaultEmptyTitle = 'Nenhum registro encontrado';
  static const defaultEmptySubtext = '';
  static const defaultErrorTitle = 'Erro';
  static const defaultErrorSubtext = 'Não foi possível listar os registros';
  static String defaultGetLabel(item) => item?.toString() ?? '';

  final String name;
  final T? value;
  final ValueChanged<T> onChanged;
  final SearchFn<T> onSearch;
  final FilterFn<T>? onFilter;
  final GetLabelFn<T> getContentLabel;
  final GetLabelFn<T> getListItemLabel;
  final bool required;
  final bool enabled;
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
    this.enabled = true,
    this.value,
    this.onFilter,
    this.emptyTitle = defaultEmptyTitle,
    this.emptySubtext = defaultEmptySubtext,
    this.errorTitle = defaultErrorTitle,
    this.errorSubtext = defaultErrorSubtext,
    GetLabelFn<T>? getContentLabel,
    GetLabelFn<T>? getListItemLabel,
  })  : getContentLabel = getContentLabel ?? defaultGetLabel,
        getListItemLabel =
            getListItemLabel ?? getContentLabel ?? defaultGetLabel,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final contentTextStyle = themeData.textTheme.subtitle1!;

    return FormField<T>(
      validator: required ? Validator.required : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: value,
      enabled: enabled,
      builder: (state) {
        final effectiveDecoration = InputDecoration(
          labelText: name,
          prefixIcon: const Icon(Icons.search_outlined),
          errorText: state.errorText,
        )
            .applyDefaults(themeData.inputDecorationTheme)
            .copyWith(enabled: enabled);
        return GestureDetector(
          onTap: enabled
              ? () => _showSearchDialog(context, onChanged: (i) {
                    onChanged(i);
                    state.didChange(i);
                  })
              : null,
          child: InputDecorator(
            decoration: effectiveDecoration,
            isEmpty: getContentLabel(value).isEmpty,
            child: Text(
              getContentLabel(value),
              style: contentTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context,
      {required ValueChanged<T> onChanged}) {
    showDialog<T>(
      context: context,
      builder: (_) => _SearchDialog<T>(
        name: name,
        searchFn: onSearch,
        filterFn: onFilter ?? defaultFilter,
        getLabelFromValue: getListItemLabel,
        onChanged: (i) {
          if (i != value) {
            onChanged(i);
          }
          Navigator.of(context).pop();
        },
        emptyTitle: emptyTitle,
        emptySubtext: emptySubtext,
        errorTitle: errorTitle,
        errorSubtext: errorSubtext,
      ),
    );
  }

  List<T> defaultFilter(List<T> items, String? search) {
    if (search == null || search.isEmpty) {
      return items;
    }
    final lowerCaseSearch = search.toLowerCase();
    return items
        .where((i) => i != null)
        .where((i) =>
            getListItemLabel(i).toLowerCase().startsWith(lowerCaseSearch))
        .toList();
  }
}

class _SearchDialog<T> extends StatefulWidget {
  final String name;
  final SearchFn<T> searchFn;
  final FilterFn<T> filterFn;
  final GetLabelFn<T> getLabelFromValue;
  final ValueChanged<T> onChanged;
  final String emptyTitle;
  final String emptySubtext;
  final String errorTitle;
  final String errorSubtext;

  const _SearchDialog({
    Key? key,
    required this.name,
    required this.searchFn,
    required this.getLabelFromValue,
    required this.filterFn,
    required this.onChanged,
    required this.emptyTitle,
    required this.emptySubtext,
    required this.errorTitle,
    required this.errorSubtext,
  }) : super(key: key);

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
  bool isLoading = false;
  Object? error;
  List<T>? totalItems;
  List<T>? filteredItems;

  @override
  void initState() {
    _searchItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: kMediumEdgeInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextFormField(
              name: widget.name,
              required: false,
              prefixIcon: const Icon(Icons.search_outlined),
              onChanged: _filterItems,
            ),
            kMediumSpacerVertical,
            if (isLoading)
              _loadingBuilder()
            else if (error != null)
              _errorBuilder(error!)
            else if (filteredItems == null || filteredItems!.isEmpty)
              _emptyBuilder()
            else
              _dataBuilder(filteredItems!)
          ],
        ),
      ),
    );
  }

  Future<void> _searchItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final items = await widget.searchFn(null);
      if (mounted) {
        setState(() {
          isLoading = false;
          totalItems = items;
          filteredItems = items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = e;
        });
      }
    }
  }

  void _filterItems(String search) {
    debouncer.run(() {
      if (totalItems != null) {
        setState(() {
          filteredItems = widget.filterFn(totalItems!, search);
        });
      }
    });
  }

  Widget _loadingBuilder() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _emptyBuilder() => Center(
        child: Empty(text: widget.emptyTitle, subtext: widget.emptySubtext),
      );

  Widget _errorBuilder(Object error) {
    debugPrint('Error on SearchTextField: $error');
    if (error is Error) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
    return Center(
      child: Empty(
        text: widget.errorTitle,
        subtext: widget.errorSubtext,
        icon: Icons.error_outline_outlined,
      ),
    );
  }

  Widget _dataBuilder(List<T> data) {
    final totalHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: totalHeight / 2),
      child: ListView.builder(
        itemCount: data.length,
        itemExtent: 50,
        shrinkWrap: true,
        itemBuilder: (_, i) {
          final item = data[i];
          return ListTile(
            onTap: () => widget.onChanged(item),
            title: Text(widget.getLabelFromValue(item)),
          );
        },
      ),
    );
  }
}
