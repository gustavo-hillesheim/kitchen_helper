import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../common/common.dart';
import '../../clients.dart';

class EditClientBloc extends AppCubit<Client> {
  final SaveClientUseCase saveUseCase;
  final GetClientUseCase getUseCase;

  EditClientBloc(this.saveUseCase, this.getUseCase) : super(const EmptyState());

  Future<Either<Failure, void>> save(Client client) {
    return saveUseCase.execute(client);
  }

  loadClient(int id) async {
    emit(const LoadingClientState());
    final result = await getUseCase.execute(id);
    result.fold(
      (f) => emit(FailureState(f)),
      (client) {
        if (client == null) {
          emit(FailureState(
              BusinessFailure('Não foi possível encontrar o cliente')));
        } else {
          emit(SuccessState(client));
        }
      },
    );
  }
}

class LoadingClientState extends ScreenState<Client> {
  const LoadingClientState();
}
