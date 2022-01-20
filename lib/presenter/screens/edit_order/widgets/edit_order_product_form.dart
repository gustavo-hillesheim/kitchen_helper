import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../presenter.dart';
import '../models/editing_order_product.dart';

class EditOrderProductForm extends StatefulWidget {
  final ValueChanged<OrderProduct> onSave;
  final EditingOrderProduct? initialValue;

  const EditOrderProductForm({
    Key? key,
    required this.onSave,
    this.initialValue,
  }) : super(key: key);

  @override
  _EditOrderProductFormState createState() => _EditOrderProductFormState();
}

class _EditOrderProductFormState extends State<EditOrderProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  RecipeIngredientSelectorItem? _selectedOrderProduct;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final initialValue = widget.initialValue!;
      _quantityController.text = Formatter.simpleNumber(initialValue.quantity);
      _selectedOrderProduct = RecipeIngredientSelectorItem(
        id: initialValue.id,
        name: initialValue.name,
        measurementUnit: initialValue.measurementUnit,
        type: RecipeIngredientType.recipe,
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
                        ? 'Editar produto'
                        : 'Adicionar produto',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  kMediumSpacerVertical,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RecipeIngredientSelector(
                        showOnly: RecipeIngredientSelectorItems.recipes,
                        recipeFilter: const RecipeFilter(
                          canBeSold: true,
                        ),
                        initialValue: selectorInitialValue,
                        onChanged: (item) => setState(() {
                          _selectedOrderProduct = item;
                        }),
                      ),
                      kSmallSpacerVertical,
                      AppTextFormField.number(
                        name: _selectedOrderProduct?.measurementUnit.label ??
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

  RecipeIngredientSelectorItem? get selectorInitialValue {
    if (widget.initialValue != null) {
      return RecipeIngredientSelectorItem(
        id: widget.initialValue!.id,
        name: widget.initialValue!.name,
        type: RecipeIngredientType.recipe,
        measurementUnit: widget.initialValue!.measurementUnit,
      );
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final selectedOrderProduct = _selectedOrderProduct!;
      final orderProduct = OrderProduct(
        id: selectedOrderProduct.id,
        quantity: double.parse(_quantityController.text.replaceAll(',', '.')),
      );
      widget.onSave(orderProduct);
    }
  }
}
