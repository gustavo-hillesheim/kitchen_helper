import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';

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
    bloc = ImportDialogBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: kLargeEdgeInsets,
        child: StreamBuilder<ScreenState<Map<String, List>?>>(
          stream: bloc.stream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data is FailureState) {
              return Text(
                (data as FailureState).failure.message,
                style: const TextStyle(color: Colors.red),
              );
            }
            if (data is SuccessState) {
              return _buildImportButton((data as SuccessState).value);
            }
            return _buildFilePickerButton(data is LoadingState);
          },
        ),
      ),
    );
  }

  Widget _buildImportButton(Map<String, List> dataToImport) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foram encontrados:', style: textTheme.headline6),
        kMediumSpacerVertical,
        if (dataToImport['ingredients']?.isNotEmpty ?? false)
          Text(
            '${dataToImport['ingredients']!.length} ingredientes',
            style: textTheme.subtitle2,
          ),
        if (dataToImport['recipes']?.isNotEmpty ?? false)
          Text(
            '${dataToImport['recipes']!.length} receitas',
            style: textTheme.subtitle2,
          ),
        if (dataToImport['orders']?.isNotEmpty ?? false)
          Text(
            '${dataToImport['orders']!.length} pedidos',
            style: textTheme.subtitle2,
          ),
        kMediumSpacerVertical,
        PrimaryButton(
          child: const Text('Importar'),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFilePickerButton(bool isLoading) {
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
