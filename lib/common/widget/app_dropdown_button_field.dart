import 'package:flutter/material.dart';

import '../common.dart';

class AppDropdownButtonField<T> extends StatelessWidget {
  final bool required;
  final String name;
  final Map<String, T> values;
  final T? value;
  final ValueChanged<T?>? onChange;

  const AppDropdownButtonField({
    Key? key,
    required this.name,
    required this.values,
    this.required = true,
    this.value,
    this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      validator: required ? Validator.required : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      value: value,
      onChanged: onChange,
      decoration: InputDecoration(
        label: Text(name),
        contentPadding: const EdgeInsets.fromLTRB(12, 22, 12, 13),
      ),
      items: values.entries
          .map((entry) => DropdownMenuItem(
                value: entry.value,
                child: Text(entry.key),
              ))
          .toList(),
    );
  }
}
