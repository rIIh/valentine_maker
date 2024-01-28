import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:valentine/theme/theme.dart';

final class ShareTemplate {
  final PainterController paint;
  final Color backgroundColor;
  final Color heartColor;
  final String? face;

  const ShareTemplate({
    required this.paint,
    required this.backgroundColor,
    required this.heartColor,
    required this.face,
  });
}

class SharePage extends StatefulWidget {
  final ShareTemplate template;

  const SharePage({
    super.key,
    required this.template,
  });

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 340))..forward();
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  bool _busy = false;
  set busy(bool value) => mounted && _busy != value ? setState(() => _busy = value) : null;
  bool get busy => _busy;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<ByteData> save() async {
    final boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: max(MediaQuery.devicePixelRatioOf(context), 4));
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!;
  }

  Future<void> share() async {
    if (busy) return;

    busy = true;
    try {
      final image = await save();
      if (kIsWeb) {
        await XFile.fromData(
          image.buffer.asUint8List(),
          name: 'valentine',
          mimeType: 'image/png',
        ).saveTo('valentine.png');

        await Share.shareXFiles(
          [XFile('valentine.png')],
          sharePositionOrigin: _repaintBoundaryKey.currentContext?.findRenderObject()?.paintBounds,
        );
      } else if (Platform.isLinux || Platform.isWindows) {
        final downloads = await getDownloadsDirectory();

        var path = await FilePicker.platform.saveFile(
          dialogTitle: 'Pick directory to save a Valentine',
          initialDirectory: downloads?.path,
          allowedExtensions: ['.png'],
          fileName: 'valentine.png',
          lockParentWindow: true,
          type: FileType.custom,
        );

        if (path == null) {
          if (downloads == null) throw StateError("No downloads folder found");
          path = '${downloads.path}/valentine.png';

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Valentine saved to Downloads folder'),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () => launchUrlString('file:$path'),
                ),
              ),
            );
          }
        }

        final file = await File(path).create(recursive: true);
        await file.writeAsBytes(image.buffer.asUint8List());
      } else {
        await Share.shareXFiles(
          [XFile.fromData(image.buffer.asUint8List(), name: 'valentine', mimeType: 'image/png')],
          sharePositionOrigin: _repaintBoundaryKey.currentContext?.findRenderObject()?.paintBounds,
        );
      }
    } finally {
      busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.template.backgroundColor,
      body: GestureDetector(
        onTap: kDebugMode ? () => _controller.forward(from: 0) : null,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: _RevealTransition(
                  animation: _controller,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 10,
                              color: context.white,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Snapshot(
                              backgroundColor: widget.template.backgroundColor,
                              heartColor: widget.template.heartColor,
                              face: widget.template.face,
                              paint: widget.template.paint,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                minimum: const EdgeInsets.only(top: 50),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => GoRouter.of(context).pop(),
                      child: Container(
                        width: 70,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(40)),
                          color: context.pink,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset('assets/icons/home.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 61),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: busy ? null : share,
                  child: Image.asset('assets/icons/share.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Snapshot extends StatelessWidget {
  final PainterController paint;
  final Color backgroundColor;
  final Color heartColor;
  final String? face;

  const Snapshot({
    super.key,
    required this.backgroundColor,
    required this.heartColor,
    required this.face,
    required this.paint,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 380,
        height: 500,
        child: Transform.translate(
          offset: const Offset(0, 25),
          child: Stack(
            children: [
              Positioned.fill(
                child: OverflowBox(
                  maxHeight: 1000000,
                  maxWidth: 1000000,
                  child: SizedBox.expand(child: ColoredBox(color: backgroundColor)),
                ),
              ),
              Center(
                child: Stack(
                  children: [
                    Image.asset(
                      color: heartColor,
                      'assets/images/maker/heart.png',
                    ),
                    if (face != null)
                      Positioned.fill(
                        child: Align(
                          alignment: const Alignment(0, -.35),
                          child: Image.asset('assets/images/maker/faces/$face.png'),
                        ),
                      ),
                  ],
                ),
              ),
              OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: SizedBox(
                  width: 100000,
                  height: 100000,
                  child: FlutterPainter(
                    controller: paint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const _RevealTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fade = Tween(begin: 1.0, end: .0).animate(CurvedAnimation(parent: animation, curve: const Interval(.0, .7)));
    final scale = Tween(begin: 1.05, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeInBack));
    final slide = Tween(begin: const Offset(0, -.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeInBack));

    final rotate = Tween(begin: 3 / 360, end: -3 / 360)
        .animate(CurvedAnimation(parent: animation, curve: const Interval(.0, 1, curve: Curves.easeOutBack)));

    return ScaleTransition(
      scale: scale,
      child: SlideTransition(
        position: slide,
        child: RotationTransition(
          turns: rotate,
          child: FillTransition(
            opacity: fade,
            color: BoxDecoration(borderRadius: BorderRadius.circular(5), color: context.white),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FillTransition extends StatelessWidget {
  final Animation<double> opacity;
  final Decoration color;
  final Widget child;

  const FillTransition({super.key, required this.opacity, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: FadeTransition(
            opacity: opacity,
            child: DecoratedBox(decoration: color),
          ),
        ),
      ],
    );
  }
}
