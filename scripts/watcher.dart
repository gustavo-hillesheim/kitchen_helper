import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

final lock = Lock();
Timer? debounceTimer;
Process? process;

void main(List<String> args) {
  runProcess(args);
  Directory.current.watch(recursive: true).listen((e) {
    final currentDir = Directory.current.path;
    if (e.path.startsWith(join(currentDir, 'lib')) ||
        e.path.startsWith(join(currentDir, 'test'))) {
      debounce(() => runProcess(args), const Duration(milliseconds: 500));
    }
  });
}

void debounce(void Function() fn, Duration duration) {
  if (debounceTimer != null && debounceTimer!.isActive) {
    debounceTimer!.cancel();
  }
  debounceTimer = Timer(duration, () {
    fn();
  });
}

Future<void> runProcess(List<String> args) {
  return lock.synchronized(() async {
    if (process != null) {
      print('[WATCHER] Killing already existing process...');
      process!.kill();
    }
    print('[WATCHER] Running "${args.join(' ')}"...');
    process = await Process.start(
      args[0],
      args.sublist(1),
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
  });
}
