import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/models/ingredient.dart';
import '../../../domain/models/measurement_unit.dart';
import '../../constants.dart';
import '../../widgets/app_text_form_field.dart';
import 'edit_ingredient_bloc.dart';

class EditIngredientScreen extends StatefulWidget {
  const EditIngredientScreen({Key? key}) : super(key: key);

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  late final EditIngredientBloc bloc;
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  MeasurementUnit? measurementUnit;
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = EditIngredientBloc(Modular.get());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo ingrediente'),
      ),
      body: Column(
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
                    ),
                    kMediumSpacerVertical,
                    Row(
                      children: [
                        Expanded(
                          child: AppTextFormField.number(
                            name: 'Quantidade',
                            controller: quantityController,
                          ),
                        ),
                        kMediumSpacerHorizontal,
                        Expanded(
                          child: DropdownButtonFormField<MeasurementUnit>(
                            value: measurementUnit,
                            onChanged: (m) {
                              setState(() {
                                measurementUnit = m;
                              });
                            },
                            decoration: const InputDecoration(
                              label: Text('Medida'),
                              border: OutlineInputBorder(),
                            ),
                            items: MeasurementUnit.values
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m.label),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    kMediumSpacerVertical,
                    AppTextFormField.number(
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
    );
  }

  void _save() async {
    final ingredient = Ingredient(
      name: nameController.text,
      quantity: double.parse(quantityController.text),
      measurementUnit: measurementUnit!,
      price: double.parse(priceController.text),
    );
    await bloc.save(ingredient);
    Modular.to.pop(true);
  }
}
