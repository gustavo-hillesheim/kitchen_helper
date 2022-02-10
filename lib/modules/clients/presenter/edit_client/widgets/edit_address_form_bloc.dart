import 'package:fpdart/fpdart.dart';

import '../../../../../common/common.dart';
import '../../../../../core/core.dart';
import '../../../clients.dart';

class EditAddressFormBloc extends AppCubit<AddressData> {
  final GetAddressDataByCepUseCase getAdressDataUseCase;

  EditAddressFormBloc(this.getAdressDataUseCase) : super(const EmptyState());

  Future<Either<Failure, AddressData>> loadAddressData(int cep) {
    return runEither(() => getAdressDataUseCase.execute(cep));
  }
}
