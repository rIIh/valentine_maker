import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valentine/constants/heart_colors.dart';
import 'package:valentine/drawing/blister_widget.dart';
import 'package:valentine/pages/share_page.dart';
import 'package:valentine/theme/theme.dart';
import 'package:valentine/utility/animated_switcher_layout.dart';
import 'package:valentine/widgets/click_detector.dart';
import 'package:valentine/widgets/color_fill_animation.dart';
import 'package:valentine/widgets/responsive_scaled_box_pixel_ratio_fix.dart';
import 'package:valentine/widgets/stickers.dart';
import 'package:valentine/widgets/toolbar.dart';

const kFaces = [
  'face_1',
  'face_2',
  'face_3',
  'face_4',
  'face_5',
  'face_6',
];

enum Steps {
  chooseFace,
  edit,
  stickers,
  snapshot(end: true);

  final bool end;

  const Steps({this.end = false});
}

class StepsMachine {
  final Steps current;

  const StepsMachine({required this.current});

  Steps? get next => switch (current) {
        Steps.chooseFace => Steps.edit,
        Steps.edit => Steps.stickers,
        Steps.stickers => Steps.snapshot,
        _ => null,
      };

  Steps? get previous => switch (current) {
        Steps.edit => Steps.chooseFace,
        Steps.stickers => Steps.edit,
        Steps.snapshot => Steps.edit,
        _ => null,
      };
}

class StickerData {
  final Offset position;
  final String image;

  const StickerData({required this.position, required this.image});
}

class StickerDragData {
  final int? index;
  final String image;

  StickerDragData(this.index, this.image);
}

class ValentineMakerPage extends StatefulWidget {
  const ValentineMakerPage({super.key});

  @override
  State<ValentineMakerPage> createState() => _ValentineMakerPageState();
}

class _ValentineMakerPageState extends State<ValentineMakerPage> with TickerProviderStateMixin {
  late final _paintController = PainterController();
  late final _floatingController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat(reverse: true);

  Offset? offset;
  late final colors = getHeartColors(context)..shuffle();
  late int heartColorIndex = Random().nextInt(colors.length);

  final GlobalKey _stickersDrawerKey = GlobalKey();
  final List<StickerData> stickers = [];

  late int faceIndex = Random().nextInt(kFaces.length + 1) - 1;

  Steps _step = Steps.chooseFace;

  Steps get step => _step;
  set step(Steps value) => mounted && _step != value ? setState(() => _step = value) : null;
  StepsMachine get _stepState => StepsMachine(current: _step);

  DefaultToolbarActions _tool = DefaultToolbarActions.pen;
  DefaultToolbarActions get tool => _tool;
  set tool(DefaultToolbarActions value) {
    if (mounted && _tool != value) setState(() => _tool = value);
    switch (tool) {
      case DefaultToolbarActions.pen:
        _paintController.freeStyleStrokeWidth = 7;
        _paintController.freeStyleMode = FreeStyleMode.draw;

      case DefaultToolbarActions.erase:
        _paintController.freeStyleStrokeWidth = 22;
        _paintController.freeStyleMode = FreeStyleMode.erase;

      default:
        _paintController.freeStyleMode = FreeStyleMode.none;
    }
  }

  int _selectedPaintColor = 0;
  int get selectedPaintColor => _selectedPaintColor;
  set selectedPaintColor(int value) {
    _paintController.freeStyleColor = paintColors[value];
    if (mounted && _selectedPaintColor != value) setState(() => _selectedPaintColor = value);
  }

  late final paintColors = [
    context.pink,
    context.green,
    context.blue,
    context.yellow,
    context.violet,
    context.red,
    context.cyan,
    context.white,
    context.black,
  ];

  @override
  void initState() {
    Future.microtask(() {
      tool = tool;
      selectedPaintColor = selectedPaintColor;

      for (final face in kFaces) {
        precacheImage(AssetImage('assets/images/maker/faces/$face.png'), context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  VoidCallback? handleHeartTap() {
    switch (step) {
      case Steps.chooseFace:
        return () {
          faceIndex++;
          if (faceIndex >= kFaces.length) faceIndex = -1;
          setState(() {});
        };

      case Steps.edit:
        switch (tool) {
          case DefaultToolbarActions.fill:
            return null;

          default:
        }

      default:
    }

    return null;
  }

  void handleBackgroundTap() {
    if (step != Steps.edit) return;
    switch (tool) {
      case DefaultToolbarActions.fill:
        heartColorIndex++;
        if (heartColorIndex >= colors.length) heartColorIndex = 0;
        setState(() {});

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: ClickDetector(
              onTapDown: (details) => offset = details.localPosition,
              onTap: handleBackgroundTap,
              child: ColorFillAnimation(
                color: colors[heartColorIndex].background,
                offset: offset,
                duration: const Duration(milliseconds: 240),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: handleHeartTap() == null,
            child: Center(
              child: AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) => Transform.translate(
                  offset: Tween(begin: Offset.zero, end: const Offset(0, 4))
                      .chain(CurveTween(curve: Curves.easeInOut))
                      .animate(_floatingController)
                      .value,
                  child: child,
                ),
                child: ClickDetector(
                  onTap: handleHeartTap(),
                  child: Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.decelerate,
                        child: Image.asset(
                          key: ValueKey(heartColorIndex),
                          color: colors[heartColorIndex].foreground,
                          'assets/images/maker/heart.png',
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: const Alignment(0, -.35),
                          child: AnimatedSwitcher(
                            switchInCurve: Curves.decelerate,
                            duration: const Duration(milliseconds: 240),
                            layoutBuilder: (currentChild, previousChildren) => currentChild ?? const SizedBox(),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: TweenSequence([
                                  TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: .5),
                                  TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: .5),
                                ]).animate(animation),
                                child: child,
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(faceIndex),
                              child: faceIndex == -1
                                  ? const SizedBox()
                                  : Image.asset(
                                      key: ValueKey(faceIndex),
                                      'assets/images/maker/faces/${kFaces[faceIndex]}.png',
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: step != Steps.edit ||
                !{
                  DefaultToolbarActions.pen,
                  DefaultToolbarActions.erase,
                  DefaultToolbarActions.blister,
                }.contains(tool),
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: 100000,
                height: 100000,
                child: RepaintBoundary(
                  child: FlutterPainter.builder(
                    controller: _paintController,
                    builder: (context, painter) => BlisterWidget(
                      active: step == Steps.edit && tool == DefaultToolbarActions.blister,
                      child: painter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(bottom: 61),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedScale(
                scale: step == Steps.snapshot ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).replace(
                    '/share',
                    extra: ShareTemplate(
                      paint: PainterController.fromValue(_paintController.value),
                      stickers: stickers,
                      backgroundColor: colors[heartColorIndex].background,
                      heartColor: colors[heartColorIndex].foreground,
                      face: faceIndex >= 0 ? kFaces[faceIndex] : null,
                    ),
                  ),
                  child: Image.asset('assets/icons/camera.png'),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(key: _stickersDrawerKey, width: 0, height: 0),
                      ),
                    ),
                    for (final (index, sticker) in stickers.indexed)
                      Positioned(
                        left: sticker.position.dx + constraints.maxWidth / 2,
                        top: sticker.position.dy + constraints.maxHeight / 2,
                        child: IgnorePointer(
                          ignoring: step != Steps.stickers,
                          child: Draggable(
                            data: StickerDragData(index, sticker.image),
                            childWhenDragging: const SizedBox(),
                            maxSimultaneousDrags: 1,
                            feedback: DraggableFeedbackSticker(image: sticker.image, scale: context.watch<Scale>()),
                            child: Image.asset(sticker.image),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => DragTarget<StickerDragData>(
                hitTestBehavior: HitTestBehavior.translucent,
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) => setState(() {
                  final offset = data.offset / context.read<Scale>().value -
                      Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

                  if (data.data.index == null) {
                    stickers.add(StickerData(position: offset, image: data.data.image));
                  } else {
                    stickers[data.data.index!] = StickerData(position: offset, image: data.data.image);
                  }
                }),
                builder: (context, candidateData, rejectedData) => const SizedBox(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              switchInCurve: Curves.ease,
              switchOutCurve: Curves.ease,
              duration: const Duration(milliseconds: 160),
              layoutBuilder: AnimatedSwitcherLayout.builder(alignment: Alignment.bottomCenter),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey({Steps.edit, Steps.stickers}.contains(step) ? step : null),
                child: !{Steps.edit, Steps.stickers}.contains(step)
                    ? const SizedBox()
                    : Container(
                        decoration: BoxDecoration(
                          color: context.background,
                          border: Border(
                            top: BorderSide(color: context.pink, width: 20),
                          ),
                        ),
                        child: DragTarget<StickerDragData>(
                          onAcceptWithDetails: (details) => setState(() => stickers.removeAt(details.data.index!)),
                          onWillAcceptWithDetails: (details) => details.data.index != null,
                          builder: (context, candidateData, rejectedData) => SizedBox(
                            width: double.infinity,
                            child: switch (step) {
                              Steps.stickers => const Stickers(),
                              Steps.edit => Toolbar(
                                  selected: tool,
                                  onSelected: (value) => tool = value,
                                  colors: paintColors,
                                  activePalette: switch (tool) {
                                    DefaultToolbarActions.erase => Palette.sizes,
                                    DefaultToolbarActions.pen => Palette.colors,
                                    DefaultToolbarActions.blister => Palette.blister,
                                    _ => Palette.none,
                                  },
                                  selectedColor: selectedPaintColor,
                                  onColorSelected: (index) => selectedPaintColor = index,
                                  selectedSize: _paintController.freeStyleStrokeWidth,
                                  onSizeSelected: (value) {
                                    switch (tool) {
                                      case DefaultToolbarActions.erase:
                                        _paintController.freeStyleStrokeWidth = value;
                                        setState(() {});

                                      default:
                                    }
                                  },
                                  actions: DefaultToolbarActions.values
                                      .map((e) => ToolbarActionData(value: e, child: e.build()))
                                      .toList(),
                                ),
                              _ => const SizedBox(),
                            },
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
                  if (_stepState.previous != null)
                    ClickDetector(
                      onTap: () => step = _stepState.previous!,
                      child: Container(
                        width: 70,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(40)),
                          color: context.pink,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: RotatedBox(
                              quarterTurns: 2,
                              child: Image.asset('assets/icons/chevron_right.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_stepState.next != null)
                    ClickDetector(
                      onTap: () => step = _stepState.next!,
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
                            child: Image.asset('assets/icons/chevron_right.png'),
                          ),
                        ),
                      ),
                    )
                  else if (step.end)
                    ClickDetector(
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
        ],
      ),
    );
  }
}
