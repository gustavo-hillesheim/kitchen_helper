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
    final isLibEvent = e.path.startsWith(join(currentDir, 'lib'));
    final isTestEvent = e.path.startsWith(join(currentDir, 'test'));
    if (isLibEvent || isTestEvent) {
      debounce(() => runProcess(args), const Duration(milliseconds: 500));
    }
  });
}

Future<void> killProcess() async {
  if (process != null) {
    print('[WATCHER] Killing existing process...');
    process!.kill();
    await process!.exitCode;
    process = null;
  }
}

void debounce(void Function() fn, Duration duration) async {
  await killProcess();
  if (debounceTimer != null && debounceTimer!.isActive) {
    debounceTimer!.cancel();
  }
  debounceTimer = Timer(duration, fn);
}

Future<void> runProcess(List<String> args) {
  return lock.synchronized(() async {
    await killProcess();
    print('[WATCHER] Running "${args.join(' ')}"...');
    process = await Process.start(
      args[0],
      args.sublist(1),
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
  });
}
