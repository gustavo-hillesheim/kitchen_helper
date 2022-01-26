import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' hide Order;

import '../../../core/core.dart';
import '../../../domain/domain.dart';

class ImportDialogBloc extends Cubit<ImportState> {
  final ImportUseCase usecase;

  ImportDialogBloc(this.usecase) : super(WaitingForFileState());

  void readData(String path) async {
    emit(ReadingFileState());
    final result = await compute(_readData, path);
    result.fold(
      (f) => emit(FailureOnReadState(f)),
      (d) => emit(ReadDataState(d)),
    );
  }

  void import(Map<String, List> data) async {
    emit(ImportingState());
    try {
      final result = await usecase.execute(data);
      result.fold(
        (f) => emit(FailureOnImportState(f)),
        (_) => emit(ImportedState()),
      );
    } catch (e, stack) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      emit(FailureOnImportState(
        const BusinessFailure('Uma falha inesperada ocorreu'),
      ));
    }
  }
}

Future<Either<Failure, Map<String, List>>> _readData(String path) async {
  try {
    final file = File(path);
    final content = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(content);
    _validateKeys(json);
    return Right(json.mapValue((v) => v as List));
  } catch (e, stack) {
    debugPrint(e.toString());
    debugPrintStack(stackTrace: stack);
    if (e is Failure) {
      return Left(e);
    }
    return const Left(BusinessFailure('Não foi possível ler o arquivo'));
  }
}

void _validateKeys(Map<String, dynamic> json) {
  final keys = ['ingredients', 'recipes', 'orders'];
  for (final key in keys) {
    if (json.containsKey(key) && json[key] is! List) {
      debugPrint('A chave $key do JSON não é uma lista');
      throw const BusinessFailure('O arquivo é inválido');
    }
    if (json.containsKey(key)) {
      for (final entity in json[key]!) {
        switch (key) {
          case 'ingredients':
            {
              try {
                Ingredient.fromJson(entity);
                break;
              } catch (e) {
                debugPrint('Erro ao converter $entity para ingrediente: $e');
                throw const BusinessFailure(
                  'Não foi possível ler os ingredientes do arquivo',
                );
              }
            }
          case 'recipes':
            {
              try {
                Recipe.fromJson(entity);
                break;
              } catch (e) {
                debugPrint('Erro ao converter $entity para receita: $e');
                throw const BusinessFailure(
                  'Não foi possível ler as receitas do arquivo',
                );
              }
            }
          case 'orders':
            {
              try {
                Order.fromJson(entity);
                break;
              } catch (e) {
                debugPrint('Erro ao converter $entity para pedido: $e');
                throw const BusinessFailure(
                  'Não foi possível ler os pedidos do arquivo',
                );
              }
            }
        }
      }
    }
  }
  json.removeWhere((key, value) => !keys.contains(key));
}

abstract class ImportState {}

class WaitingForFileState extends ImportState {}

class ReadingFileState extends ImportState {}

class FailureOnReadState extends ImportState {
  final Failure failure;

  FailureOnReadState(this.failure);
}

class ReadDataState extends ImportState {
  final Map<String, List> data;

  ReadDataState(this.data);
}

class ImportingState extends ImportState {}

class FailureOnImportState extends ImportState {
  final Failure failure;

  FailureOnImportState(this.failure);
}

class ImportedState extends ImportState {}
