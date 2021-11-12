import 'dart:io';

import 'package:path/path.dart';

void main(List<String> args) {
  Process? process;
  Future<void> runProcess() async {
    if (process != null) {
      print('[WATCHER] Killing already existing process...');
      process!.kill();
    }
    print('[WATCHER] Running ${args.join(' ')}');
    final whereResult = await Process.run('where', [args[0]]);
    final commandPath = whereResult.stdout.toString().replaceAll('\n', '');
    process = await Process.start(
      commandPath,
      args.sublist(1),
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
  }

  runProcess();
  Directory.current.watch(recursive: true).listen((e) {
    final currentDir = Directory.current.path;
    if (e.path.startsWith(join(currentDir, 'lib')) ||
        e.path.startsWith(join(currentDir, 'test'))) {
      runProcess();
    }
  });
}
