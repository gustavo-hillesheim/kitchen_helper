import '../../../../common/common.dart';
import '../../clients.dart';

class EditClientBloc extends AppCubit<Client> {
  final SaveClientUseCase saveUseCase;
  final GetClientUseCase getUseCase;

  EditClientBloc(this.saveUseCase, this.getUseCase) : super(const EmptyState());
}
