import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../common.dart';

typedef TileBuilder<T> = Widget Function(BuildContext context, T entity);
typedef DeletedMessageFn<T> = String Function(T entity);
typedef OnLoadFn = Future<void> Function();

class ListPageTemplate<T extends ListingDto, E extends Entity<int>>
    extends StatelessWidget {
  final String title;
  final ListPageBloc<T, E> bloc;
  final TileBuilder<T> tileBuilder;
  final DeletedMessageFn<T> deletedMessage;
  final String emptyText;
  final String emptySubtext;
  final String emptyActionText;
  final VoidCallback onAdd;
  final OnLoadFn onLoad;
  final Widget? headerBottom;

  ListPageTemplate({
    Key? key,
    required this.title,
    required this.bloc,
    required this.tileBuilder,
    required this.deletedMessage,
    required this.emptyText,
    required this.emptySubtext,
    required this.emptyActionText,
    required this.onAdd,
    OnLoadFn? onLoad,
    this.headerBottom,
  })  : onLoad = onLoad ?? (() => bloc.load()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWithHeader(
        header: AppBarHeader(
          title: title,
          context: context,
          action: AppBarHeaderAction(
            label: 'Adicionar',
            icon: Icons.add,
            onPressed: onAdd,
          ),
          bottom: headerBottom,
        ),
        body: BottomCard(
          child: _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() => ScreenStateBuilder<List<T>>(
        stateStream: bloc.stream,
        successBuilder: (_, recipes) {
          if (recipes.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: kSmallEdgeInsets,
            itemCount: recipes.length,
            itemBuilder: (context, index) => _buildTile(
              context,
              recipes[index],
            ),
          );
        },
        errorBuilder: (_, failure) => _buildErrorState(failure.message),
      );

  Widget _buildEmptyState() => Empty(
        text: emptyText,
        subtext: emptySubtext,
        action: ElevatedButton(
          onPressed: onAdd,
          child: Text(emptyActionText),
        ),
      );

  Widget _buildErrorState(String message) => Empty(
        icon: Icons.error_outline_outlined,
        text: 'Erro',
        subtext: message,
        action: ElevatedButton(
          onPressed: onLoad,
          child: const Text('Tente novamente'),
        ),
      );

  Widget _buildTile(BuildContext context, T entity) => Padding(
        padding: const EdgeInsets.only(bottom: kSmallSpace),
        child: ActionsSlider(
          child: tileBuilder(context, entity),
          onDelete: () => _tryDelete(context, entity),
        ),
      );

  void _tryDelete(BuildContext context, T listingEntity) async {
    final result = await bloc.delete(listingEntity.id);
    result.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _tryDelete(context, listingEntity),
          ),
        ),
      );
    }, (entity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deletedMessage(listingEntity)),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _trySave(context, entity),
          ),
        ),
      );
    });
  }

  void _trySave(BuildContext context, E entity) async {
    final result = await bloc.save(entity);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: () => _trySave(context, entity),
            ),
          ),
        );
      },
      (_) {},
    );
  }
}

mixin ListPageBloc<T, E extends Entity<int>>
    implements BlocBase<ScreenState<List<T>>> {
  UseCase<Object?, List<T>> get getAllUseCase;

  UseCase<int, E?> get getUseCase;

  UseCase<int, void> get deleteUseCase;

  UseCase<E, E> get saveUseCase;

  Future<void> load() async {
    emit(LoadingState<List<T>>());
    final result = await getAllUseCase.execute(const NoParams());
    result.fold(
      (failure) => emit(FailureState<List<T>>(failure)),
      (value) => emit(SuccessState<List<T>>(value)),
    );
  }

  Future<Either<Failure, E>> delete(int id) async {
    final getResult = await getUseCase.execute(id);
    return getResult.bindFuture<E>((entity) async {
      if (entity == null) {
        return Left(BusinessFailure('Registro não encontrado'));
      }
      return deleteUseCase.execute(id).then((result) {
        load();
        return result.map((_) => entity);
      });
    }).run();
  }

  Future<Either<Failure, E>> save(E entity) async {
    return saveUseCase.execute(entity).then((result) {
      load();
      return result;
    });
  }
}
