import '../../../../../presenter/screens/states.dart';
import '../../../domain/domain.dart';

class OrderListTileBloc extends AppCubit<List<ListingOrderProductDto>> {
  final GetListingOrderProductsUseCase getListingOrderProductsUseCase;

  OrderListTileBloc(
    this.getListingOrderProductsUseCase,
  ) : super(const EmptyState());

  Future<void> loadProducts(int orderId) async {
    runEither(() => getListingOrderProductsUseCase.execute(orderId));
  }
}
