import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';
import 'edit_ingredient_bloc.dart';

class EditIngredientScreen extends StatefulWidget {
  final int? id;
  final EditIngredientBloc? bloc;

  const EditIngredientScreen({
    Key? key,
    this.id,
    this.bloc,
  }) : super(key: key);

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();

  static Future<bool?> navigate([int? id]) {
    return Modular.to.pushNamed<bool?>(
      '/edit-ingredient',
      arguments: id,
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

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ?? EditIngredientBloc(Modular.get(), Modular.get());
    if (widget.id != null) {
      bloc.stream
          .where((state) => state is SuccessState<Ingredient>)
          .map((state) => (state as SuccessState<Ingredient>).value)
          .listen(_setControllersValues);
      bloc.loadIngredient(widget.id!);
    }
  }

  void _setControllersValues(Ingredient ingredient) {
    setState(() {
      nameController.text = ingredient.name;
      quantityController.text = Formatter.simpleNumber(ingredient.quantity);
      costController.text = ingredient.cost.toStringAsFixed(2);
      measurementUnit = ingredient.measurementUnit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.id != null ? 'Editar ingrediente' : 'Novo ingrediente'),
      ),
      body: StreamBuilder(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          return Stack(
            children: [
              if (state is FailureState)
                _buildFailureState(state.failure)
              else if (state is LoadingIngredientState)
                const Center(child: CircularProgressIndicator())
              else
                _buildForm(state is SuccessState ? state.value : null),
              if (state is LoadingState) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFailureState(Failure failure) => Center(
        child: Text(failure.message, style: const TextStyle(color: Colors.red)),
      );

  Widget _buildForm([Ingredient? ingredient]) {
    return Form(
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
            child: PrimaryButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() => Positioned.fill(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final ingredient = Ingredient(
        id: widget.id,
        name: nameController.text,
        quantity: double.parse(quantityController.text.replaceAll(',', '.')),
        measurementUnit: measurementUnit!,
        cost: double.parse(costController.text.replaceAll(',', '.')),
      );
      final result = await bloc.save(ingredient);
      result.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        ),
        (_) => Modular.to.pop(true),
      );
    }
  }
}
