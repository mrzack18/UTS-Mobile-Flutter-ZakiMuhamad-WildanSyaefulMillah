import 'package:flutter/widgets.dart';

import 'image_helper_stub.dart' if (dart.library.io) 'image_helper_io.dart';

Widget buildAdaptiveImage(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  return buildAdaptiveImageInternal(
    path,
    width: width,
    height: height,
    fit: fit,
  );
}
