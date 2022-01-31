import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../common.dart';

typedef SuccessBuilder<T> = Widget Function(BuildContext, T);
typedef LoadingBuilder = WidgetBuilder;
typedef ErrorBuilder = Widget Function(BuildContext, Failure);

class ScreenStateBuilder<T> extends StatelessWidget {
  final Stream<ScreenState<T>> stateStream;
  final SuccessBuilder<T> successBuilder;
  final LoadingBuilder loadingBuilder;
  final ErrorBuilder errorBuilder;

  const ScreenStateBuilder({
    Key? key,
    required this.stateStream,
    required this.successBuilder,
    required this.errorBuilder,
    this.loadingBuilder = _defaultLoadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState<T>>(
      stream: stateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data is LoadingState) {
          return loadingBuilder(context);
        }
        final state = snapshot.data;
        if (state is FailureState) {
          final failureState = state as FailureState;
          return errorBuilder(context, failureState.failure);
        }
        final value = (state as SuccessState<T>).value;
        return successBuilder(context, value);
      },
    );
  }

  static Widget _defaultLoadingBuilder(_) {
    return const Center(child: CircularProgressIndicator());
  }
}
