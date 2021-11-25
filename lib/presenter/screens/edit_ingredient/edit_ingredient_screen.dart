import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/presenter/screens/edit_ingredient/edit_ingredient_bloc.dart';
import 'package:kitchen_helper/presenter/widgets/app_text_form_field.dart';

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppTextFormField(
                      name: 'Nome',
                      controller: nameController,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextFormField.number(
                            name: 'Quantidade',
                            controller: quantityController,
                          ),
                        ),
                        const SizedBox(width: 16),
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
                    SizedBox(height: 16),
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
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size.fromHeight(48)),
              ),
              onPressed: _save,
              child: Text('Salvar'),
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
