import '../../../../common/common.dart';
import '../../domain/domain.dart';

class ClientsListBloc extends AppCubit<List<ListingClientDto>>
    with ListPageBloc<ListingClientDto, Client> {
  @override
  DeleteClientUseCase deleteUseCase;
  @override
  GetClientsUseCase getAllUseCase;

  @override
  GetClientUseCase getUseCase;

  @override
  SaveClientUseCase saveUseCase;

  ClientsListBloc(
    this.deleteUseCase,
    this.getAllUseCase,
    this.getUseCase,
    this.saveUseCase,
  ) : super(const EmptyState());

  @override
  Future<void> load([ClientsFilter? filter]) async {
    runEither(() => getAllUseCase.execute(filter));
  }
}
