import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/screens/edit_order/widgets/calculated_value.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

import '../../../../domain/domain.dart';
import '../../../../extensions.dart';
import '../../../presenter.dart';
import '../edit_recipe_bloc.dart';

class GeneralInformationForm extends StatelessWidget {
  static const unableToCalculateProfitText = 'Não é possível calcular o lucro'
      ' ainda';

  final TextEditingController quantityProducedController;
  final TextEditingController notesController;
  final TextEditingController quantitySoldController;
  final TextEditingController priceController;
  final ValueNotifier<bool> canBeSoldNotifier;
  final ValueNotifier<MeasurementUnit?> measurementUnitNotifier;
  final double cost;
  final EditRecipeBloc bloc;
  final Recipe? initialValue;

  const GeneralInformationForm({
    Key? key,
    required this.quantityProducedController,
    required this.notesController,
    required this.quantitySoldController,
    required this.priceController,
    required this.canBeSoldNotifier,
    required this.measurementUnitNotifier,
    required this.cost,
    required this.bloc,
    required this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: kMediumEdgeInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextFormField.number(
                        name: 'Quantidade produzida',
                        initialValue: initialValue?.quantityProduced,
                        controller: quantityProducedController,
                      ),
                    ),
                    kSmallSpacerHorizontal,
                    Expanded(
                      child: measurementUnitNotifier.builder(
                        (_, value, onChange) => MeasurementUnitSelector(
                          value: value,
                          onChange: onChange,
                        ),
                      ),
                    ),
                  ],
                ),
                kSmallSpacerVertical,
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                  ),
                  child: AppTextFormField(
                    name: 'Anotações',
                    initialValue: initialValue?.notes,
                    multiline: true,
                    controller: notesController,
                    required: false,
                  ),
                ),
                kSmallSpacerVertical,
                canBeSoldNotifier.builder(
                  (_, value, onChange) => CheckboxListTile(
                    value: value,
                    onChanged: (v) => onChange(v ?? false),
                    title: const Text('Pode ser vendida?'),
                  ),
                ),
                canBeSoldNotifier.builder(
                  (_, canBeSold, __) => canBeSold
                      ? Column(
                          children: [
                            kSmallSpacerVertical,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AppTextFormField.number(
                                    required: canBeSold,
                                    name: 'Quantidade vendida',
                                    initialValue: initialValue?.quantitySold,
                                    controller: quantitySoldController,
                                  ),
                                ),
                                kSmallSpacerHorizontal,
                                Expanded(
                                  child: AppTextFormField.money(
                                    required: canBeSold,
                                    name: 'Preço de venda',
                                    initialValue: initialValue?.price,
                                    controller: priceController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            kMediumSpacerVertical,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalculatedValue(
                    title: 'Custo',
                    value: cost,
                    calculation: const [],
                  ),
                ),
                kMediumSpacerHorizontal,
                Expanded(child: _buildProfitIndicators()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfitIndicators() {
    return MultiValueListenableBuilder(
      valueListenables: [
        canBeSoldNotifier,
        quantityProducedController,
        quantitySoldController,
        priceController,
        measurementUnitNotifier,
      ],
      builder: (_, values, __) {
        if (!values.elementAt(0)) {
          return const SizedBox.shrink();
        }
        final quantityProduced = Parser.money(values.elementAt(1).text);
        final quantitySold = Parser.money(values.elementAt(2).text);
        final pricePerQuantitySold = Parser.money(values.elementAt(3).text);
        final MeasurementUnit? measurementUnit = values.elementAt(4);

        if (quantityProduced == null ||
            quantitySold == null ||
            pricePerQuantitySold == null ||
            measurementUnit == null) {
          return const Text(GeneralInformationForm.unableToCalculateProfitText);
        }

        final quantitySoldRatio = quantityProduced / quantitySold;
        final costPerQuantitySold = cost / quantitySoldRatio;

        return CalculatedValue(
          title: 'Lucro por ${Formatter.simpleNumber(quantitySold)} '
              '${measurementUnit.label}',
          value: pricePerQuantitySold - costPerQuantitySold,
          calculation: [
            CalculationStep('Preço', value: pricePerQuantitySold),
            CalculationStep('Custo', value: -costPerQuantitySold),
          ],
        );
      },
    );
  }
}
