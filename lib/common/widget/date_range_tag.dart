import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_helper/common/common.dart';

class DateRangeTag extends StatelessWidget {
  static final dateWithYearFormat = DateFormat('dd/MM/yyyy');
  static final dateWithoutYearFormat = DateFormat('dd/MM');
  final String identifier;
  final DateTime? start;
  final DateTime? end;
  final VoidCallback? onDelete;
  final bool isActive;

  const DateRangeTag({
    Key? key,
    required this.identifier,
    this.isActive = false,
    this.start,
    this.end,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToggleableTag(
      label: _createLabel(),
      isActive: isActive,
      onChange: (_) => onDelete,
    );
  }

  String _createLabel() {
    final start = this.start;
    final end = this.end;
    if (start != null && end != null) {
      return _createRangeLabel(start, end);
    }
    if (start != null) {
      return _createAfterLabel(start);
    }
    if (end != null) {
      return _createBeforeLabel(end);
    }
    return 'Sem período definido';
  }

  String _createRangeLabel(DateTime start, DateTime end) {
    final format = _getEffectiveFormat([start, end]);
    return '$identifier entre ${format.format(start)} e ${format.format(end)}';
  }

  String _createAfterLabel(DateTime start) {
    final format = _getEffectiveFormat([start]);
    return '$identifier após ${format.format(start)}';
  }

  String _createBeforeLabel(DateTime end) {
    final format = _getEffectiveFormat([end]);
    return '$identifier antes de ${format.format(end)}';
  }

  DateFormat _getEffectiveFormat(List<DateTime> dates) {
    final now = DateTime.now();
    for (final date in dates) {
      if (date.year != now.year) {
        return dateWithYearFormat;
      }
    }
    return dateWithoutYearFormat;
  }
}
