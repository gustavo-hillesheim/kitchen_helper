import 'dart:async';

import 'package:flutter/material.dart';

typedef OnPressedCallback = FutureOr<void> Function();

class PrimaryButton extends StatefulWidget {
  final Widget child;
  final OnPressedCallback? onPressed;
  final Size? size;
  final bool? isLoading;

  const PrimaryButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.size = const Size.fromHeight(48),
    this.isLoading,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  Future? _future;
  late ButtonStyle buttonStyle;

  @override
  void didChangeDependencies() {
    buttonStyle = ButtonStyle(
      minimumSize: MaterialStateProperty.all(widget.size),
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.secondary,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_future != null) {
      return FutureBuilder(
        future: _future,
        builder: (_, snapshot) {
          final state = snapshot.connectionState;
          if (state == ConnectionState.done || state == ConnectionState.none) {
            return _buildButton();
          }
          return _buildLoadingButton();
        },
      );
    }
    if (widget.isLoading == true) {
      return _buildLoadingButton();
    }
    return _buildButton();
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: null,
      child: Center(
          child: CircularProgressIndicator(
        color: Theme.of(context).backgroundColor,
      )),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: _onPressed,
      child: widget.child,
    );
  }

  VoidCallback? get _onPressed {
    if (widget.onPressed != null) {
      return () {
        final result = widget.onPressed!();
        if (result is Future) {
          setState(() {
            _future = result;
          });
          result.then((_) => setState(() {
                _future = null;
              }));
        }
      };
    }
    return null;
  }
}
