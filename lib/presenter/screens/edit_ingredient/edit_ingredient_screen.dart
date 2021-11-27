import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/models/ingredient.dart';
import '../../../domain/models/measurement_unit.dart';
import '../../constants.dart';
import '../../utils/formatter.dart';
import '../../widgets/app_text_form_field.dart';
import '../../widgets/measurement_unit_selector.dart';
import 'edit_ingredient_bloc.dart';

class EditIngredientScreen extends StatefulWidget {
  final Ingredient? initialValue;

  const EditIngredientScreen({
    Key? key,
    this.initialValue,
  }) : super(key: key);

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();

  static Future<bool?> navigate([Ingredient? ingredient]) {
    return Modular.to.pushNamed<bool?>(
      '/edit-ingredient',
      arguments: ingredient,
    );
  }
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  MeasurementUnit? measurementUnit;
  late final EditIngredientBloc bloc;
  int? id;

  @override
  void initState() {
    super.initState();
    bloc = EditIngredientBloc(Modular.get());
    final initialValue = widget.initialValue;
    if (initialValue != null) {
      id = initialValue.id;
      nameController.text = initialValue.name;
      quantityController.text = Formatter.simple(initialValue.quantity);
      measurementUnit = initialValue.measurementUnit;
      priceController.text = initialValue.price.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialValue != null
            ? 'Editar ingrediente'
            : 'Novo ingrediente'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: kMediumEdgeInsets,
                  child: Column(
                    children: [
                      AppTextFormField(
                        name: 'Nome',
                        controller: nameController,
                        example: 'Farinha',
                      ),
                      kMediumSpacerVertical,
                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextFormField.number(
                                name: 'Quantidade',
                                controller: quantityController,
                              ),
                            ),
                            kMediumSpacerHorizontal,
                            Expanded(
                              child: MeasurementUnitSelector(
                                value: measurementUnit,
                                onChange: (m) {
                                  setState(() {
                                    measurementUnit = m;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      kMediumSpacerVertical,
                      AppTextFormField.money(
                        name: 'Custo',
                        controller: priceController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: kMediumEdgeInsets,
              child: ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size.fromHeight(48),
                  ),
                ),
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final ingredient = Ingredient(
        id: id,
        name: nameController.text,
        quantity: double.parse(quantityController.text),
        measurementUnit: measurementUnit!,
        price: double.parse(priceController.text),
      );
      await bloc.save(ingredient);
      Modular.to.pop(true);
    }
  }
}
