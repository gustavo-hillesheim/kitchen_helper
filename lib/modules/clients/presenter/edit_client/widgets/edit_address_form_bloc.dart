import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';

class EditAddressFormBloc extends AppCubit<AddressData> {
  final GetAddressDataByCepUseCase getAdressDataUseCase;

  EditAddressFormBloc(this.getAdressDataUseCase) : super(const EmptyState());

  Future<Either<Failure, AddressData>> loadAddressData(int cep) {
    return runEither(() => getAdressDataUseCase.execute(cep));
  }
}
