import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

import '../../../../domain/domain.dart';
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
                      child: ValueListenableBuilder<MeasurementUnit?>(
                        valueListenable: measurementUnitNotifier,
                        builder: (_, measurementUnit, __) =>
                            MeasurementUnitSelector(
                          value: measurementUnit,
                          onChange: (m) => measurementUnitNotifier.value = m,
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
                  ),
                ),
                kSmallSpacerVertical,
                ValueListenableBuilder<bool>(
                  valueListenable: canBeSoldNotifier,
                  builder: (_, canBeSold, __) => CheckboxListTile(
                    value: canBeSold,
                    onChanged: (v) => canBeSoldNotifier.value = v ?? false,
                    title: const Text('Pode ser vendida?'),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: canBeSoldNotifier,
                  builder: (_, canBeSold, __) => canBeSold
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
            Text('Custo total: ${Formatter.money(cost)}'),
            _buildProfitIndicators(),
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kSmallSpacerVertical,
            Text(_getProfitPerQuantitySoldLabel(
              quantityProduced: quantityProduced,
              quantitySold: quantitySold,
              pricePerQuantitySold: pricePerQuantitySold,
              measurementUnit: measurementUnit,
            )),
            kSmallSpacerVertical,
            Text(_getTotalProfitLabel(
              quantityProduced: quantityProduced,
              quantitySold: quantitySold,
              pricePerQuantitySold: pricePerQuantitySold,
            )),
          ],
        );
      },
    );
  }

  String _getProfitPerQuantitySoldLabel({
    required double quantityProduced,
    required double quantitySold,
    required double pricePerQuantitySold,
    required MeasurementUnit measurementUnit,
  }) {
    final profitPerQuantitySold = bloc.calculateProfitPerQuantitySold(
      quantityProduced: quantityProduced,
      quantitySold: quantitySold,
      pricePerQuantitySold: pricePerQuantitySold,
      totalCost: cost,
    );
    return 'Lucro por '
        '${Formatter.simple(quantitySold)} '
        '${measurementUnit.label}: '
        '${Formatter.money(profitPerQuantitySold)}';
  }

  String _getTotalProfitLabel({
    required double quantityProduced,
    required double quantitySold,
    required double pricePerQuantitySold,
  }) {
    final profit = bloc.calculateTotalProfit(
      quantityProduced: quantityProduced,
      quantitySold: quantitySold,
      pricePerQuantitySold: pricePerQuantitySold,
      totalCost: cost,
    );
    return 'Lucro total: ${Formatter.money(profit)}';
  }
}
