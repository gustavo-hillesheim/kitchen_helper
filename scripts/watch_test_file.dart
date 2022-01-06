import 'dart:io';

import 'package:path/path.dart' as path;

import 'watcher.dart';

void main(List<String> args) async {
  var fileName = args[0];
  if (!fileName.endsWith('_test.dart')) {
    fileName += '_test.dart';
  }
  final filePath = await findTestFilePath(fileName);
  runOnFileChange(['fvm', 'flutter', 'test', filePath]);
}

Future<String> findTestFilePath(String fileName) {
  final testFolder = path.relative('test');
  return Directory(testFolder)
      .list(recursive: true)
      .where((fileEntity) => fileEntity is File)
      .map((fileEntity) => fileEntity.path)
      .firstWhere((filePath) => path.basename(filePath) == fileName);
}
