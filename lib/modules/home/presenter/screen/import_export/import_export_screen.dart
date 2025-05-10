import 'package:flutter/material.dart';

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
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Exportar dados'),
              ),
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
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Importar dados'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
