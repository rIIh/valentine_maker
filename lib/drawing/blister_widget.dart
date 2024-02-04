import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:valentine/drawing/blister_drawable.dart';

class BlisterWidget extends StatefulWidget {
  final bool active;
  final Widget child;

  const BlisterWidget({
    Key? key,
    required this.child,
    this.active = false,
  }) : super(key: key);

  @override
  State<BlisterWidget> createState() => _BlisterWidgetState();
}

class _BlisterWidgetState extends State<BlisterWidget> {
  ui.Image? _image;
  PathDrawable? drawable;
  PathDrawable? blister;

  Future<ui.Image> getImage(String asset, int height, int width) async {
    if (_image != null) return _image!;

    final ByteData assetImageByteData = await rootBundle.load(asset);
    image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List())!;
    image.Image resizeImage = image.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();

    return _image = frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }

    return FutureBuilder<ui.Image>(
      future: getImage('assets/images/noise.png', 300, 300),
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(data: ui.Image _) => RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _DragGestureDetector: GestureRecognizerFactoryWithHandlers<_DragGestureDetector>(
                () => _DragGestureDetector(
                  onHorizontalDragDown: _handleHorizontalDragDown,
                  onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                  onHorizontalDragUp: _handleHorizontalDragUp,
                ),
                (_) {},
              ),
            },
            child: widget.child,
          ),
        _ => widget.child,
      },
    );
  }

  FreeStyleSettings get settings => PainterController.of(context).value.settings.freeStyle;

  ShapeSettings get shapeSettings => PainterController.of(context).value.settings.shape;

  void _handleHorizontalDragDown(Offset globalPosition) {
    if (this.drawable != null || this.blister != null) return;

    final PathDrawable drawable;
    final PathDrawable blister;
    if (widget.active) {
      drawable = BlisterDrawable(
        path: [_globalToLocal(globalPosition)],
        color: settings.color,
        strokeWidth: settings.strokeWidth,
      );
      blister = BlisterDrawable(
        image: _image!,
        path: [_globalToLocal(globalPosition)],
        color: settings.color,
        strokeWidth: settings.strokeWidth,
      );

      PainterController.of(context).addDrawables([drawable, blister]);
    } else {
      return;
    }

    this.drawable = drawable;
    this.blister = blister;
  }

  void _handleHorizontalDragUpdate(Offset globalPosition) {
    final drawable = this.drawable;
    final blister = this.blister;
    if (drawable == null || blister == null) return;

    final newDrawable = drawable.copyWith(path: List<Offset>.from(drawable.path)..add(_globalToLocal(globalPosition)));
    final newBlister = blister.copyWith(path: List<Offset>.from(blister.path)..add(_globalToLocal(globalPosition)));
    PainterController.of(context).replaceDrawable(drawable, newDrawable, newAction: false);
    PainterController.of(context).replaceDrawable(blister, newBlister, newAction: false);
    this.drawable = newDrawable;
    this.blister = newBlister;
  }

  void _handleHorizontalDragUp() {
    drawable = null;
    blister = null;
  }

  Offset _globalToLocal(Offset globalPosition) {
    final getBox = context.findRenderObject() as RenderBox;

    return getBox.globalToLocal(globalPosition);
  }
}

class _DragGestureDetector extends OneSequenceGestureRecognizer {
  _DragGestureDetector({
    required this.onHorizontalDragDown,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragUp,
  });

  final ValueSetter<Offset> onHorizontalDragDown;
  final ValueSetter<Offset> onHorizontalDragUpdate;
  final VoidCallback onHorizontalDragUp;

  bool _isTrackingGesture = false;

  @override
  void addPointer(PointerEvent event) {
    if (!_isTrackingGesture) {
      resolve(GestureDisposition.accepted);
      startTrackingPointer(event.pointer);
      _isTrackingGesture = true;
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      onHorizontalDragDown(event.position);
    } else if (event is PointerMoveEvent) {
      onHorizontalDragUpdate(event.position);
    } else if (event is PointerUpEvent) {
      onHorizontalDragUp();
      stopTrackingPointer(event.pointer);
      _isTrackingGesture = false;
    }
  }

  @override
  String get debugDescription => '_DragGestureDetector';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
