import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

Timer? debounceTimer;
Process? process;
final processMap = <Process, bool?>{};

void main(List<String> args) {
  runOnFileChange(args);
}

void runOnFileChange(List<String> args) {
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
    processMap[process!] = false;
    process!.kill();
    await process!.exitCode;
    process = null;
  }
}

void debounce(void Function() fn, Duration duration) async {
  if (debounceTimer != null && debounceTimer!.isActive) {
    debounceTimer!.cancel();
  }
  debounceTimer = Timer(duration, fn);
}

Future<void> runProcess(List<String> args) async {
  await killProcess();
  print('[WATCHER] Running "${args.join(' ')}"...');
  final newProcess = await Process.start(
    args[0],
    args.sublist(1),
    mode: ProcessStartMode.normal,
    runInShell: true,
  );
  processMap[newProcess] = true;
  utf8.decoder
      .bind(newProcess.stdout)
      .takeWhile((_) => processMap[newProcess] ?? false)
      .listen(print);
  utf8.decoder
      .bind(newProcess.stderr)
      .takeWhile((_) => processMap[newProcess] ?? false)
      .listen(print);
  process = newProcess;
}
