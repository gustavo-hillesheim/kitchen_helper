import 'package:flutter/material.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';

import '../utils/validator.dart';

class MeasurementUnitSelector extends StatelessWidget {
  @visibleForTesting
  static const dropdownFieldKey = ValueKey('dropdown-field-key');
  final MeasurementUnit? value;
  final bool required;
  final ValueChanged<MeasurementUnit?> onChange;

  const MeasurementUnitSelector({
    Key? key,
    this.value,
    this.required = true,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MeasurementUnit>(
      key: dropdownFieldKey,
      validator: required ? Validator.required : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      value: value,
      onChanged: onChange,
      decoration: const InputDecoration(
        label: Text('Medida'),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.fromLTRB(12, 22, 12, 13),
      ),
      items: MeasurementUnit.values
          .map((m) => DropdownMenuItem(
                value: m,
                child: Text(m.label),
              ))
          .toList(),
    );
  }
}
