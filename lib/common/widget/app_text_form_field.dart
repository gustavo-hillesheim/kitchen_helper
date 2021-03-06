import 'package:flutter/material.dart';

import '../common.dart';

class AppTextFormField extends StatefulWidget {
  final String name;
  final bool required;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? prefixText;
  final Widget? prefixIcon;
  final String? example;
  final bool? multiline;
  final String? initialValue;
  final int? maxLength;

  const AppTextFormField({
    Key? key,
    required this.name,
    this.required = true,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.prefixText,
    this.prefixIcon,
    this.example,
    this.multiline,
    this.initialValue,
    this.maxLength,
  }) : super(key: key);

  AppTextFormField.number({
    Key? key,
    required this.name,
    this.required = true,
    this.onChanged,
    this.controller,
    this.prefixText,
    this.prefixIcon,
    this.example = '10',
    this.multiline,
    this.maxLength,
    num? initialValue,
  })  : keyboardType = TextInputType.number,
        initialValue =
            initialValue != null ? Formatter.simpleNumber(initialValue) : null,
        super(key: key);

  AppTextFormField.money({
    Key? key,
    required this.name,
    this.required = true,
    this.onChanged,
    this.controller,
    this.example = '9.90',
    this.multiline,
    this.maxLength,
    this.prefixIcon,
    num? initialValue,
  })  : keyboardType = TextInputType.number,
        prefixText = 'R\$',
        initialValue = initialValue?.toStringAsFixed(2),
        super(key: key);

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    controller = widget.controller ?? TextEditingController();
    if (controller.text.isEmpty && initialValue != null) {
      controller.text = initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.required ? Validator.required : null,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: widget.multiline ?? false ? null : 1,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        counterText: "",
        labelText: widget.name,
        prefixText: widget.prefixText,
        prefixIcon: widget.prefixIcon,
        hintText: widget.example != null ? 'Ex.: ${widget.example}' : null,
      ),
      controller: controller,
    );
  }
}
