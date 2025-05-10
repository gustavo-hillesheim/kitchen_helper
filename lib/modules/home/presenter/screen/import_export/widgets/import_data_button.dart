import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/modules/home/components/data_importer.dart';

class ImportDataButton extends StatefulWidget {
  const ImportDataButton({super.key});

  @override
  State<ImportDataButton> createState() => _ImportDataButtonState();
}

class _ImportDataButtonState extends State<ImportDataButton> {
  final _dataImporter = Modular.get<DataImporter>();
  bool _isLoading = false;

  void _importData() async {
    setState(() {
      _isLoading = true;
    });
    final dataToImport = await _chooseFile();
    if (dataToImport != null) {
      try {
        await _dataImporter.importData(dataToImport);
        _showMessage(
          'Dados importados com sucesso!',
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        );
      } catch (e, st) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: st);
        _showMessage(
          'Não foi possível importar todos os dados!',
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        );
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _chooseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['json'],
        withData: true,
        type: FileType.custom,
        dialogTitle: 'Escolha o arquivo para importar',
      );
      if (result == null || result.files.isEmpty) return null;
      final content = utf8.decode(result.files.first.bytes!);
      return jsonDecode(content);
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      _showMessage('O conteúdo do arquivo escolhido não é válido');
      return null;
    }
  }

  void _showMessage(
    String text, {
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: TextStyle(color: foregroundColor),
          ),
          backgroundColor: backgroundColor,
          closeIconColor: foregroundColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _importData,
      child: _isLoading
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Text('Importar dados'),
    );
  }
}
