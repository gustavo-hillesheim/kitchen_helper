import 'package:flutter/material.dart';

import 'widgets/export_data_button.dart';
import 'widgets/import_data_button.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importar/Exportar dados'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ExportDataButton(),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(child: Divider()),
              const SizedBox(width: 16),
              Text('ou'),
              const SizedBox(width: 16),
              Expanded(child: Divider()),
              const SizedBox(width: 16),
            ],
          ),
          Expanded(
            child: Center(
              child: ImportDataButton(),
            ),
          ),
        ],
      ),
    );
  }
}
