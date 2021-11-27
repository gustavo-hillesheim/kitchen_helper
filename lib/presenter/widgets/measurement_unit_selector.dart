import 'package:flutter/material.dart';

import '../../domain/models/measurement_unit.dart';
import '../utils/validator.dart';

class MeasurementUnitSelector extends StatelessWidget {
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
      validator: (v) => required ? Validator.required(v) : null,
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
