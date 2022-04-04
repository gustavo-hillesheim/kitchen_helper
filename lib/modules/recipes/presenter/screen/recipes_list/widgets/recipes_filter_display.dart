import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../../../../extensions.dart';
import '../../../../../../common/common.dart';

class RecipesFilterDisplay extends StatefulWidget {
  final ValueChanged<RecipesFilter?> onFilter;

  const RecipesFilterDisplay({
    Key? key,
    required this.onFilter,
  }) : super(key: key);

  @override
  State<RecipesFilterDisplay> createState() => _RecipesFilterDisplayState();
}

class _RecipesFilterDisplayState extends State<RecipesFilterDisplay> {
  RecipesFilter? _filter;

  @override
  Widget build(BuildContext context) {
    return FilterWithTags(
      onOpenFilter: _showFilterForm,
      tags: [
        if (_filter?.name != null && _filter!.name!.isNotEmpty)
          Tag(
            label: 'Nome inclui: ${_filter?.name}',
            onDelete: _removeNameFromFilter,
          ),
        if (_filter?.canBeSold != null)
          ToggleableTag(
            label: _filter?.canBeSold == true
                ? 'Pode ser vendida'
                : 'Não pode ser vendida',
            isActive: true,
            onChange: (_) => _removeCanBeSold(),
          ),
      ],
    );
  }

  void _showFilterForm() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: _RecipesFilterForm(
            initialValue: _filter,
            onFilter: (newFilter) {
              _setFilter(newFilter);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _removeNameFromFilter() {
    _setFilter(RecipesFilter(name: null, canBeSold: _filter?.canBeSold));
  }

  void _removeCanBeSold() {
    _setFilter(RecipesFilter(name: _filter?.name, canBeSold: null));
  }

  void _setFilter(RecipesFilter? filter) {
    setState(() {
      _filter = filter;
      widget.onFilter(filter);
    });
  }
}

class _RecipesFilterForm extends StatefulWidget {
  final RecipesFilter? initialValue;
  final ValueChanged<RecipesFilter> onFilter;

  const _RecipesFilterForm({
    Key? key,
    required this.initialValue,
    required this.onFilter,
  }) : super(key: key);

  @override
  State<_RecipesFilterForm> createState() => __RecipesFilterFormState();
}

class __RecipesFilterFormState extends State<_RecipesFilterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _canBeSoldNotifier = ValueNotifier<bool?>(null);

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _nameController.text = widget.initialValue?.name ?? '';
      _canBeSoldNotifier.value = widget.initialValue?.canBeSold;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kMediumEdgeInsets,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrar receitas',
                style: Theme.of(context).textTheme.headline6),
            kMediumSpacerVertical,
            AppTextFormField(
              name: 'Nome',
              controller: _nameController,
              required: false,
            ),
            kSmallSpacerVertical,
            _canBeSoldNotifier.builder(
              (_, value, onChange) => AppDropdownButtonField<bool?>(
                name: 'Pode ser vendida?',
                value: value,
                required: false,
                values: const {
                  'Sem filtro': null,
                  'Pode ser vendida': true,
                  'Não pode ser vendida': false,
                },
                onChange: onChange,
              ),
            ),
            kMediumSpacerVertical,
            PrimaryButton(
              child: const Text('Filtrar'),
              onPressed: _onFilter,
            ),
          ],
        ),
      ),
    );
  }

  void _onFilter() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final canBeSold = _canBeSoldNotifier.value;
      final filter = RecipesFilter(name: name, canBeSold: canBeSold);
      widget.onFilter(filter);
    }
  }
}
