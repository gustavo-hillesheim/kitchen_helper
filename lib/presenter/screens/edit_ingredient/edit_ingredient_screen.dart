import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/domain.dart';
import '../../constants.dart';
import '../../utils/formatter.dart';
import '../../widgets/app_text_form_field.dart';
import '../../widgets/measurement_unit_selector.dart';
import '../../widgets/widgets.dart';
import 'edit_ingredient_bloc.dart';

class EditIngredientScreen extends StatefulWidget {
  final Ingredient? initialValue;
  final EditIngredientBloc? bloc;

  const EditIngredientScreen({
    Key? key,
    this.initialValue,
    this.bloc,
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
  final costController = TextEditingController();
  late final EditIngredientBloc bloc;
  MeasurementUnit? measurementUnit;
  int? id;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ?? EditIngredientBloc(Modular.get());
    final initialValue = widget.initialValue;
    if (initialValue != null) {
      id = initialValue.id;
      nameController.text = initialValue.name;
      quantityController.text = Formatter.simple(initialValue.quantity);
      measurementUnit = initialValue.measurementUnit;
      costController.text = initialValue.cost.toStringAsFixed(2);
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
                        controller: costController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: kMediumEdgeInsets,
              child: StreamBuilder<EditIngredientState>(
                  stream: bloc.stream,
                  builder: (_, snapshot) {
                    return PrimaryButton(
                      onPressed: _save,
                      child: const Text('Salvar'),
                      isLoading: snapshot.data is LoadingState,
                    );
                  }),
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
        quantity: double.parse(quantityController.text.replaceAll(',', '.')),
        measurementUnit: measurementUnit!,
        cost: double.parse(costController.text.replaceAll(',', '.')),
      );
      final state = await bloc.save(ingredient);
      if (state is SuccessState) {
        Modular.to.pop(true);
      } else if (state is FailureState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure.message)),
        );
      }
    }
  }
}
