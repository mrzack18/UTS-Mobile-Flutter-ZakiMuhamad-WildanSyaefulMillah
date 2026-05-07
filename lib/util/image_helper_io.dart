import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildAdaptiveImageInternal(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  return Image.file(File(path), width: width, height: height, fit: fit);
}
