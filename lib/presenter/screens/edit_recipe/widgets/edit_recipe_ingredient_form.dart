import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

import '../../../../domain/domain.dart';
import '../models/editing_recipe_ingredient.dart';
import 'recipe_ingredient_selector.dart';

class EditRecipeIngredientForm extends StatefulWidget {
  final ValueChanged<RecipeIngredient> onSave;
  final EditingRecipeIngredient? initialValue;
  final int? recipeToIgnore;

  const EditRecipeIngredientForm({
    Key? key,
    required this.onSave,
    this.recipeToIgnore,
    this.initialValue,
  }) : super(key: key);

  @override
  _EditRecipeIngredientFormState createState() =>
      _EditRecipeIngredientFormState();
}

class _EditRecipeIngredientFormState extends State<EditRecipeIngredientForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  SelectorItem? _selectedRecipeIngredient;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final initialValue = widget.initialValue!;
      _quantityController.text = Formatter.simple(initialValue.quantity);
      _selectedRecipeIngredient = SelectorItem(
        id: initialValue.id,
        name: initialValue.name,
        measurementUnit: initialValue.measurementUnit,
        type: initialValue.type,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kMediumEdgeInsets,
      child: Center(
        child: Material(
          borderRadius: BorderRadius.circular(kSmallSpace),
          child: Padding(
            padding: kMediumEdgeInsets,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.initialValue != null
                        ? 'Editar ingrediente'
                        : 'Adicionar ingrediente',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  kMediumSpacerVertical,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RecipeIngredientSelector(
                        initialValue: widget.initialValue,
                        recipeToIgnore: widget.recipeToIgnore,
                        onChanged: (item) => setState(() {
                          _selectedRecipeIngredient = item;
                        }),
                      ),
                      kSmallSpacerVertical,
                      AppTextFormField.number(
                        name:
                            _selectedRecipeIngredient?.measurementUnit.label ??
                                'Quantidade',
                        controller: _quantityController,
                      ),
                    ],
                  ),
                  kMediumSpacerVertical,
                  PrimaryButton(
                    child: const Text('Salvar'),
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final selectedRecipeIngredient = _selectedRecipeIngredient!;
      final recipeIngredient = RecipeIngredient(
        id: selectedRecipeIngredient.id,
        type: selectedRecipeIngredient.type,
        quantity: double.parse(_quantityController.text.replaceAll(',', '.')),
      );
      widget.onSave(recipeIngredient);
    }
  }
}