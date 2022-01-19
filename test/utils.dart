import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> saveImage(Finder finder, String path) async {
  print('saving image');
  final image = await captureImage(finder.evaluate().first);
  print('got image');
  final imageData = await image.toByteData(format: ui.ImageByteFormat.png);
  print('got image data');
  final buffer = imageData!.buffer;
  print('got buffer');
  final file = File(path);
  print('created file');
  final uint8List =
      buffer.asUint8List(imageData.offsetInBytes, imageData.lengthInBytes);
  print('got uin8List ${uint8List.length}');
  file.writeAsBytesSync(uint8List);
  /*for (var i = 0; i < uint8List.length; i += 8) {
    var end = i + 8;
    if (end > uint8List.length) {
      end = uint8List.length - 1;
    }
    file.writeAsBytesSync(
      uint8List.getRange(i, end).toList(),
      mode: FileMode.append,
    );
  }*/
  print('worte');
  print('Saved image at ${file.absolute.path}');
}

Future<ui.Image> captureImage(Element element) {
  assert(element.renderObject != null);
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent! as RenderObject;
  }
  assert(!renderObject.debugNeedsPaint);
  final OffsetLayer layer = renderObject.debugLayer! as OffsetLayer;
  return layer.toImage(renderObject.paintBounds);
}
