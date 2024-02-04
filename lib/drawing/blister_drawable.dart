import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';

class BlisterDrawable extends FreeStyleDrawable {
  final ui.Image? image;

  BlisterDrawable({
    this.image,
    required super.path,
    super.strokeWidth = 1,
    super.color = Colors.black,
    super.hidden = false,
  });

  @override
  Paint get paint => super.paint.copyWith(
        maskFilter: const MaskFilter.blur(BlurStyle.solid, 4),
        imageFilter: image != null ? ui.ImageFilter.blur(sigmaX: .5, sigmaY: .5) : null,
        shader: image != null
            ? ImageShader(
                image!,
                TileMode.repeated,
                TileMode.repeated,
                Matrix4.identity().storage,
              )
            : null,
      );

  @override
  FreeStyleDrawable copyWith({bool? hidden, List<Offset>? path, Color? color, double? strokeWidth}) {
    return BlisterDrawable(
      image: image,
      hidden: hidden ?? this.hidden,
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
