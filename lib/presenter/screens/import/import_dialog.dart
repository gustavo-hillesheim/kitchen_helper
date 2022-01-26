import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/core/core.dart';

import '../../presenter.dart';
import 'import_dialog_bloc.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({Key? key}) : super(key: key);

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  late ImportDialogBloc bloc;

  @override
  void initState() {
    bloc = ImportDialogBloc(Modular.get());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (bloc.state is ImportingState || bloc.state is ReadingFileState) {
          return false;
        }
        return true;
      },
      child: Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: kLargeEdgeInsets,
          child: StreamBuilder<ImportState>(
            stream: bloc.stream,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data is ReadingFileState) {
                return _buildFilePickerButton(isLoading: true);
              }
              if (data is FailureOnReadState) {
                return _buildFailureText('Erro ao ler arquivo', data.failure);
              }
              if (data is ReadDataState) {
                return _buildImportForm(data: data.data);
              }
              if (data is ImportingState) {
                return _buildImportForm(isLoading: true);
              }
              if (data is FailureOnImportState) {
                return _buildFailureText(
                    'Erro ao importar dados', data.failure);
              }
              if (data is ImportedState) {
                return _buildImportedState();
              }
              // is WaitingForFileState
              return _buildFilePickerButton(isLoading: false);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImportedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados importados com sucesso!',
          style: Theme.of(context).textTheme.headline6,
        ),
        kMediumSpacerVertical,
        PrimaryButton(
          child: const Text('Finalizar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildImportForm({
    Map<String, List>? data,
    bool isLoading = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data != null) ..._buildFoundDataTexts(data),
        if (isLoading)
          Text(
            'Importando...',
            style: Theme.of(context).textTheme.headline6,
          ),
        kMediumSpacerVertical,
        PrimaryButton(
          isLoading: isLoading,
          child: const Text('Importar'),
          onPressed: data != null ? () => bloc.import(data) : () {},
        ),
      ],
    );
  }

  List<Widget> _buildFoundDataTexts(Map<String, List> dataToImport) {
    final textTheme = Theme.of(context).textTheme;
    final ingredients = dataToImport['ingredients'];
    final recipes = dataToImport['recipes'];
    final orders = dataToImport['orders'];
    return [
      Text('Foram encontrados:', style: textTheme.headline6),
      kMediumSpacerVertical,
      if (ingredients?.isNotEmpty ?? false)
        Text(
          '${ingredients!.length} ingredientes',
          style: textTheme.subtitle2,
        ),
      if (recipes?.isNotEmpty ?? false)
        Text('${recipes!.length} receitas', style: textTheme.subtitle2),
      if (orders?.isNotEmpty ?? false)
        Text('${orders!.length} pedidos', style: textTheme.subtitle2),
    ];
  }

  Widget _buildFailureText(String message, Failure failure) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$message: ${failure.message}',
          style: const TextStyle(color: Colors.red),
        ),
        kMediumSpacerVertical,
        PrimaryButton(
          child: const Text('Finalizar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildFilePickerButton({required bool isLoading}) {
    return PrimaryButton(
      isLoading: isLoading,
      child: const Text('Escolha o arquivo para importar'),
      onPressed: _handleFilePickerButtonTap,
    );
  }

  void _handleFilePickerButtonTap() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['json'],
      type: FileType.custom,
    );
    if (result != null) {
      bloc.readData(result.files.single.path!);
    }
  }
}
