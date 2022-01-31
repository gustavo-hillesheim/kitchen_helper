import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common.dart';

class AppDateTimeField extends StatelessWidget {
  final String name;
  final bool required;
  final TextEditingController? controller;
  final DateTime? initialValue;
  final ValueChanged<DateTime?>? onChanged;

  const AppDateTimeField({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: required ? Validator.required : null,
      format: DateFormat('dd/MM/yyyy HH:mm'),
      decoration: InputDecoration(labelText: name),
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentValue ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.combine(date, time);
        } else {
          return currentValue;
        }
      },
    );
  }
}
