import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../constants.dart';
import '../screens/states.dart';
import 'widgets.dart';

typedef TileBuilder<T> = Widget Function(BuildContext context, T entity);
typedef DeletedMessageFn<T> = String Function(T entity);

class ListPageTemplate<T> extends StatelessWidget {
  final String title;
  final ListPageBloc<T> bloc;
  final TileBuilder<T> tileBuilder;
  final DeletedMessageFn<T> deletedMessage;
  final String emptyText;
  final String emptySubtext;
  final String emptyActionText;
  final VoidCallback onAdd;
  final Widget? headerBottom;

  const ListPageTemplate({
    Key? key,
    required this.title,
    required this.bloc,
    required this.tileBuilder,
    required this.deletedMessage,
    required this.emptyText,
    required this.emptySubtext,
    required this.emptyActionText,
    required this.onAdd,
    this.headerBottom,
  }) : super(key: key);

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
          return RefreshIndicator(
            onRefresh: bloc.load,
            child: ListView.builder(
              padding: kSmallEdgeInsets,
              itemCount: recipes.length,
              itemBuilder: (context, index) => _buildTile(
                context,
                recipes[index],
              ),
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
          onPressed: bloc.load,
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

  void _tryDelete(BuildContext context, T entity) async {
    final result = await bloc.delete(entity);
    result.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _tryDelete(context, entity),
          ),
        ),
      );
    }, (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deletedMessage(entity)),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _trySave(context, entity),
          ),
        ),
      );
    });
  }

  void _trySave(BuildContext context, T entity) async {
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

mixin ListPageBloc<T> implements BlocBase<ScreenState<List<T>>> {
  UseCase<NoParams, List<T>> get getUseCase;

  UseCase<T, void> get deleteUseCase;

  UseCase<T, T> get saveUseCase;

  Future<void> load() async {
    emit(LoadingState<List<T>>());
    final result = await getUseCase.execute(const NoParams());
    result.fold(
      (failure) => emit(FailureState<List<T>>(failure)),
      (value) => emit(SuccessState<List<T>>(value)),
    );
  }

  Future<Either<Failure, void>> delete(T entity) async {
    return deleteUseCase.execute(entity).then((result) {
      load();
      return result;
    });
  }

  Future<Either<Failure, T>> save(T entity) async {
    return saveUseCase.execute(entity).then((result) {
      load();
      return result;
    });
  }
}
