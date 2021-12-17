import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../constants.dart';
import '../../../widgets/widgets.dart';
import 'recipe_ingredient_selector.dart';

class EditRecipeIngredientForm extends StatefulWidget {
  final ValueChanged<RecipeIngredient> onSave;
  final RecipeIngredient? initialValue;

  const EditRecipeIngredientForm({
    Key? key,
    required this.onSave,
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
                    child: Text('Salvar'),
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
