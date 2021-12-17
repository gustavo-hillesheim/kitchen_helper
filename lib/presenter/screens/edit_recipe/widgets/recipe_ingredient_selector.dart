import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/core.dart';
import '../../../../domain/domain.dart';
import '../../../presenter.dart';
import '../../../utils/utils.dart';
import '../models/editing_recipe_ingredient.dart';
import 'recipe_ingredient_selector_service.dart';

class RecipeIngredientSelector extends StatefulWidget {
  final EditingRecipeIngredient? initialValue;
  final ValueChanged<SelectorItem?> onChanged;

  const RecipeIngredientSelector({
    Key? key,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RecipeIngredientSelector> createState() =>
      _RecipeIngredientSelectorState();
}

class _RecipeIngredientSelectorState extends State<RecipeIngredientSelector> {
  late final RecipeIngredientSelectorService service;
  SelectorItem? initialValue;

  @override
  void initState() {
    super.initState();
    service = RecipeIngredientSelectorService(Modular.get(), Modular.get());
    if (widget.initialValue != null) {
      initialValue = SelectorItem(
        id: widget.initialValue!.id,
        type: widget.initialValue!.type,
        name: widget.initialValue!.name,
        measurementUnit: widget.initialValue!.measurementUnit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<SelectorItem>(
      selectedItem: initialValue,
      showSearchBox: true,
      onFind: (_) => service.getItems().throwOnFailure(),
      validator: Validator.required,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      filterFn: _filterFn,
      itemAsString: (item) => item?.name ?? '',
      dropdownBuilderSupportsNullItem: false,
      dropdownBuilder: (_, item) => Text(item?.name ?? ''),
      loadingBuilder: _loadingBuilder,
      emptyBuilder: _emptyBuilder,
      errorBuilder: _errorBuilder,
      onChanged: widget.onChanged,
    );
  }

  bool _filterFn(SelectorItem? item, String? search) {
    if (item == null) {
      return false;
    }
    if (search == null) {
      return true;
    }
    return item.name.toLowerCase().startsWith(search.toLowerCase());
  }

  Widget _loadingBuilder(_, __) => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _emptyBuilder(_, __) => const Empty(
        text: 'Nenhum registro encontrado',
        subtext: 'Adicione ingredientes ou receitas e eles aparecerão aqui',
      );

  Widget _errorBuilder(_, __, ___) => const Empty(
        text: 'Erro',
        subtext: 'Não foi possível listar os possíveis ingredientes',
        icon: Icons.error_outline_outlined,
      );
}

class SelectorItem {
  final int id;
  final String name;
  final RecipeIngredientType type;
  final MeasurementUnit measurementUnit;

  SelectorItem({
    required this.id,
    required this.name,
    required this.type,
    required this.measurementUnit,
  });
}
