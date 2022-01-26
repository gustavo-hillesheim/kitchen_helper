import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';

import '../states.dart';

class ImportDialogBloc extends AppCubit<Map<String, List>?> {
  ImportDialogBloc() : super(const EmptyState());

  void readData(String path) async {
    runEither(() => compute(_readData, path));
  }
}

Future<Either<Failure, Map<String, List>?>> _readData(String path) async {
  try {
    final file = File(path);
    final content = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(content);
    _validateKeys(json);
    return Right(json.mapValue((v) => v as List));
  } catch (e) {
    return Left(BusinessFailure('Could not read file: ${e.toString()}'));
  }
}

void _validateKeys(Map<String, dynamic> json) {
  final keys = ['ingredients', 'recipes', 'orders'];
  for (final key in keys) {
    if (json.containsKey(key) && json[key] is! List) {
      throw Exception('O arquivo é inválido');
    }
  }
  json.removeWhere((key, value) => !keys.contains(key));
}
