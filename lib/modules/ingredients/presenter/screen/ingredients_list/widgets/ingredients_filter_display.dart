import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../domain/domain.dart';

class IngredientsFilterDisplay extends StatefulWidget {
  final ValueChanged<IngredientsFilter?> onFilter;

  const IngredientsFilterDisplay({
    Key? key,
    required this.onFilter,
  }) : super(key: key);

  @override
  State<IngredientsFilterDisplay> createState() =>
      _IngredientsFilterDisplayState();
}

class _IngredientsFilterDisplayState extends State<IngredientsFilterDisplay> {
  IngredientsFilter? _filter;

  @override
  Widget build(BuildContext context) {
    return FilterWithTags(
      onOpenFilter: _showIngredientsFilterForm,
      tags: [
        if (_filter?.name != null && _filter!.name!.isNotEmpty)
          Tag(
            label: 'Nome inclui: ${_filter!.name!}',
            onDelete: _removeNameFromFilter,
          ),
      ],
    );
  }

  void _removeNameFromFilter() {
    _setFilter(const IngredientsFilter(name: null));
  }

  void _setFilter(IngredientsFilter? filter) {
    setState(() {
      _filter = filter;
      widget.onFilter(filter);
    });
  }

  void _showIngredientsFilterForm() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: _IngredientsFilterForm(
            initialValue: _filter,
            onFilter: (filter) {
              _setFilter(filter);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _IngredientsFilterForm extends StatefulWidget {
  final IngredientsFilter? initialValue;
  final ValueChanged<IngredientsFilter> onFilter;

  const _IngredientsFilterForm({
    Key? key,
    required this.onFilter,
    this.initialValue,
  }) : super(key: key);

  @override
  State<_IngredientsFilterForm> createState() => __IngredientsFilterFormState();
}

class __IngredientsFilterFormState extends State<_IngredientsFilterForm> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _nameController.text = widget.initialValue!.name ?? '';
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
            Text(
              'Filtrar ingredients',
              style: Theme.of(context).textTheme.headline6,
            ),
            kMediumSpacerVertical,
            AppTextFormField(
              name: 'Nome',
              required: false,
              controller: _nameController,
            ),
            kMediumSpacerVertical,
            PrimaryButton(child: const Text('Filtrar'), onPressed: _onFilter),
          ],
        ),
      ),
    );
  }

  void _onFilter() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final filter = IngredientsFilter(name: name);
      widget.onFilter(filter);
    }
  }
}
