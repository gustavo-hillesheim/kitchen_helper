import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart';

import '../../../../core/core.dart';
import '../model/states.dart';

part 'get_address_data_by_cep_usecase.g.dart';

class GetAddressDataByCepUseCase extends UseCase<int, AddressData> {
  final Dio dio;

  GetAddressDataByCepUseCase(this.dio);

  @override
  Future<Either<Failure, AddressData>> execute(int cep) async {
    if (cep.toString().length < 8) {
      return Left(InvalidCepFailure(cep));
    }
    final result = await dio.get(_getSearchCepUrl(cep));
    if (result.statusCode == HttpStatus.ok) {
      final data = result.data;
      if (data['erro'] == true) {
        return Left(NonExistingCepFailure(cep));
      }
      return Right(AddressData.fromJson(data));
    } else {
      return Left(InvalidCepFailure(cep));
    }
  }

  String _getSearchCepUrl(int cep) {
    return 'https://viacep.com.br/ws/$cep/json';
  }
}

@JsonSerializable(createToJson: false)
class AddressData extends Equatable {
  @JsonKey(name: 'logradouro')
  final String street;
  @JsonKey(name: 'complemento')
  final String complement;
  @JsonKey(name: 'localidade')
  final String city;
  @JsonKey(name: 'bairro')
  final String neighborhood;
  @JsonKey(name: 'uf')
  final States state;

  const AddressData({
    required this.street,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      _$AddressDataFromJson(json);

  @override
  List<Object?> get props => [street, complement, neighborhood, city, state];
}

class InvalidCepFailure extends Failure {
  InvalidCepFailure(int cep) : super('O CEP "$cep" é inválido');
}

class NonExistingCepFailure extends Failure {
  NonExistingCepFailure(int cep) : super('O CEP "$cep" não existe');
}
