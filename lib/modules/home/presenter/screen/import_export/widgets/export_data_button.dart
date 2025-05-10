import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/modules/home/components/data_exporter.dart';
import 'package:share_plus/share_plus.dart';

class ExportDataButton extends StatefulWidget {
  const ExportDataButton({super.key});

  @override
  State<ExportDataButton> createState() => _ExportDataButtonState();
}

class _ExportDataButtonState extends State<ExportDataButton> {
  final _dataExporter = Modular.get<DataExporter>();
  bool _isLoading = false;

  void _exportData() async {
    setState(() {
      _isLoading = true;
    });
    final data = await _dataExporter.exportData();
    if (mounted) {
      final jsonData = const JsonEncoder.withIndent('  ').convert(data);
      final shareParams = ShareParams(
        files: [
          XFile.fromData(
            utf8.encode(jsonData),
            mimeType: 'text/plain',
          ),
        ],
        fileNameOverrides: ['ajudante_de_cozinha.json'],
      );
      SharePlus.instance.share(shareParams);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _exportData,
      child: _isLoading
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Text('Exportar dados'),
    );
  }
}
