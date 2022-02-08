import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/domain/model/states.dart';
import 'package:kitchen_helper/modules/clients/domain/usecase/usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late GetAddressDataByCepUseCase usecase;
  late Dio dio;

  setUp(() {
    dio = DioMock();
    usecase = GetAddressDataByCepUseCase(dio);
  });

  test('WHEN called with a valid CEP SHOULD return AddressData', () async {
    const fakeAddressData = AddressData(
      street: 'Street',
      complement: 'Complement',
      neighborhood: 'Neighborhood',
      city: 'City',
      state: States.SP,
    );
    const fakeResponse = {
      "cep": "12345-678",
      "logradouro": "Street",
      "complemento": "Complement",
      "bairro": "Neighborhood",
      "localidade": "City",
      "uf": "SP",
      "ibge": "1",
      "gia": "",
      "ddd": "1",
      "siafi": "1"
    };
    when(() => dio.get('https://viacep.com.br/ws/12345678/json'))
        .thenAnswer((_) async => Response(
              requestOptions: FakeRequestOptions(),
              statusCode: HttpStatus.ok,
              data: fakeResponse,
            ));

    final result = await usecase.execute(12345678);

    expect(result.getRight().toNullable(), fakeAddressData);
  });

  test('WHEN called with an invalid CEP SHOULD return Failure', () async {
    when(() => dio.get('https://viacep.com.br/ws/12345678/json'))
        .thenAnswer((invocation) async => Response(
              requestOptions: FakeRequestOptions(),
              statusCode: HttpStatus.badRequest,
            ));

    // Doesn't pass length validation
    var result = await usecase.execute(1234567);

    var failure = result.getLeft().toNullable();
    expect(failure, isA<InvalidCepFailure>());

    // Doesn't pass API validation
    result = await usecase.execute(12345678);

    failure = result.getLeft().toNullable();
    expect(failure, isA<InvalidCepFailure>());
  });

  test('WHEN called with an non-existing CEP SHOULD return Failure', () async {
    when(() => dio.get('https://viacep.com.br/ws/12345678/json'))
        .thenAnswer((invocation) async => Response(
              requestOptions: FakeRequestOptions(),
              statusCode: HttpStatus.ok,
              data: {'erro': true},
            ));

    final result = await usecase.execute(12345678);

    final failure = result.getLeft().toNullable();
    expect(failure, isA<NonExistingCepFailure>());
  });
}

class DioMock extends Mock implements Dio {}

class FakeRequestOptions extends Fake implements RequestOptions {}
