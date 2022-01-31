import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../../../extensions.dart';
import '../../../../domain/domain.dart';

class EditDiscountForm extends StatefulWidget {
  final Discount? initialValue;
  final ValueChanged<Discount> onSave;

  const EditDiscountForm({
    Key? key,
    this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditDiscountFormState createState() => _EditDiscountFormState();
}

class _EditDiscountFormState extends State<EditDiscountForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _valueController = TextEditingController();
  final _typeNotifier = ValueNotifier<DiscountType?>(null);

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _reasonController.text = widget.initialValue!.reason;
      _valueController.text =
          Formatter.simpleNumber(widget.initialValue!.value);
      _typeNotifier.value = widget.initialValue!.type;
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
                        ? 'Editar desconto'
                        : 'Adicionar desconto',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  kMediumSpacerVertical,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextFormField(
                        name: 'Motivo',
                        controller: _reasonController,
                      ),
                      kMediumSpacerVertical,
                      _typeNotifier.builder(
                        (_, value, onChange) =>
                            AppDropdownButtonField<DiscountType>(
                          name: 'Tipo',
                          value: value,
                          onChange: onChange,
                          values: {
                            DiscountType.fixed.label: DiscountType.fixed,
                            DiscountType.percentage.label:
                                DiscountType.percentage,
                          },
                        ),
                      ),
                      kMediumSpacerVertical,
                      _typeNotifier.builder(
                        (_, type, __) => AppTextFormField.number(
                          name: type?.label ?? 'Valor',
                          controller: _valueController,
                          prefixText: type == DiscountType.fixed
                              ? 'R\$'
                              : (type == DiscountType.percentage ? '%' : null),
                        ),
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

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final discount = Discount(
        reason: _reasonController.text,
        value: double.parse(_valueController.text),
        type: _typeNotifier.value!,
      );
      widget.onSave(discount);
    }
  }
}
