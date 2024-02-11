import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valentine/pages/valentine_maker_page.dart';
import 'package:valentine/theme/sounds.dart';
import 'package:valentine/utility/intersperse_extensions.dart';
import 'package:valentine/widgets/responsive_scaled_box_pixel_ratio_fix.dart';

class Stickers extends StatefulWidget {
  const Stickers({super.key});

  @override
  State<Stickers> createState() => _StickersState();
}

class _StickersState extends State<Stickers> {
  List<String> stickers = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    final stickers = manifestMap.keys.where((element) => element.startsWith('assets/images/maker/stickers/')).toList();

    setState(() => this.stickers = stickers);
  }

  @override
  Widget build(BuildContext context) {
    final rows = stickers.split();

    return RestorationScope(
      restorationId: 'colors',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          height: 150,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      for (final row in [rows.$1, rows.$2].map((e) => e.toList()))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (final image in row)
                              SizedBox(width: 66, height: 66, child: DraggableSticker(image: image)),
                          ].intersperse(const SizedBox(width: 22)).toList(),
                        ),
                    ].intersperse(const SizedBox(height: 18)).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DraggableSticker extends StatelessWidget {
  const DraggableSticker({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      maxSimultaneousDrags: 1,
      data: StickerDragData(null, image),
      onDragStarted: () => Audio.clickDown(),
      onDragEnd: (_) => Audio.clickUp(),
      feedback: DraggableFeedbackSticker(image: image, scale: context.watch<Scale>()),
      child: Image.asset(image),
    );
  }
}

class DraggableFeedbackSticker extends StatefulWidget {
  final Scale? scale;

  const DraggableFeedbackSticker({
    super.key,
    required this.image,
    this.scale,
  });

  final String image;

  @override
  State<DraggableFeedbackSticker> createState() => _DraggableFeedbackStickerState();
}

class _DraggableFeedbackStickerState extends State<DraggableFeedbackSticker> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 80))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale?.value ?? 1.0;

    return ScaleTransition(
      alignment: Alignment.center,
      scale: Tween(begin: 1.0 * scale, end: 1.1 * scale).animate(_controller),
      child: Image.asset(widget.image),
    );
  }
}

extension IterableX<T> on Iterable<T> {
  (Iterable<T>, Iterable<T>) split([double alignment = 0]) {
    return (
      take(length * (alignment + 1) ~/ 2),
      skip(length * (alignment + 1) ~/ 2),
    );
  }
}
