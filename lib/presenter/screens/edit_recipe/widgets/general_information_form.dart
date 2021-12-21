import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../constants.dart';
import '../../../widgets/widgets.dart';

class GeneralInformationForm extends StatelessWidget {
  final TextEditingController quantityProducedController;
  final TextEditingController notesController;
  final TextEditingController quantitySoldController;
  final TextEditingController priceController;
  final ValueNotifier<bool> canBeSoldNotifier;
  final ValueNotifier<MeasurementUnit?> measurementUnitNotifier;

  const GeneralInformationForm({
    Key? key,
    required this.quantityProducedController,
    required this.notesController,
    required this.quantitySoldController,
    required this.priceController,
    required this.canBeSoldNotifier,
    required this.measurementUnitNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextFormField.number(
                name: 'Quantidade produzida',
                controller: quantityProducedController,
              ),
            ),
            kSmallSpacerHorizontal,
            Expanded(
              child: ValueListenableBuilder<MeasurementUnit?>(
                valueListenable: measurementUnitNotifier,
                builder: (_, measurementUnit, __) => MeasurementUnitSelector(
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
                            controller: quantitySoldController,
                          ),
                        ),
                        kSmallSpacerHorizontal,
                        Expanded(
                          child: AppTextFormField.money(
                            required: canBeSold,
                            name: 'Preço de venda',
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
    );
  }
}
