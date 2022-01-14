import 'package:flutter/material.dart';

import '../presenter.dart';

class CalculatedValue extends StatelessWidget {
  final String title;
  final double value;
  final List<CalculationStep> calculation;

  const CalculatedValue({
    Key? key,
    required this.title,
    required this.value,
    required this.calculation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatTile(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          kSmallSpacerVertical,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('R\$'),
              Text(
                Formatter.currency(value, symbol: false),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          kSmallSpacerVertical,
          for (var i = 0; i < calculation.length; i++) ...[
            _buildCalculationRow(calculation[i], sign: i > 0),
            if (i < calculation.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculationRow(CalculationStep value, {required bool sign}) {
    const normalTextStyle = TextStyle(fontSize: 12);
    const currencySymbolTextStyle = TextStyle(fontSize: 10);

    return Row(
      children: [
        SizedBox(
          width: 8,
          child: sign
              ? Center(
                  child: Text(
                    value.value < 0 ? '-' : '+',
                    style: normalTextStyle,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        kExtraSmallSpacerHorizontal,
        const Text('R\$', style: currencySymbolTextStyle),
        Text(
          Formatter.currency(value.value.abs(), symbol: false),
          style: normalTextStyle,
        ),
        const Spacer(),
        Text(value.description, style: normalTextStyle),
      ],
    );
  }
}

class CalculationStep {
  final double value;
  final String description;

  CalculationStep(
    this.description, {
    required this.value,
  });
}
