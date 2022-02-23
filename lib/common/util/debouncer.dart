import 'dart:async';

typedef DebounceFn = void Function();

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(DebounceFn fn) {
    _cancelTimer();
    _scheduleRun(fn);
  }

  void _cancelTimer() {
    final timer = _timer;
    if (timer != null && timer.isActive) {
      timer.cancel();
    }
  }

  void _scheduleRun(DebounceFn fn) {
    _timer = Timer(delay, fn);
  }
}
