import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:go_router/go_router.dart';
import 'package:valentine/constants/heart_colors.dart';
import 'package:valentine/theme/theme.dart';
import 'package:valentine/widgets/color_fill_animation.dart';
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
  snapshot(end: true),
  share(end: true);

  final bool end;

  const Steps({this.end = false});
}

class StepsMachine {
  final Steps current;

  const StepsMachine({required this.current});

  Steps? get next => switch (current) {
        Steps.chooseFace => Steps.edit,
        Steps.edit => Steps.snapshot,
        _ => null,
      };

  Steps? get previous => switch (current) {
        Steps.edit => Steps.chooseFace,
        Steps.snapshot => Steps.edit,
        _ => null,
      };
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

  late int faceIndex = Random().nextInt(kFaces.length + 1) - 1;

  Steps _step = Steps.chooseFace;
  Steps get step => _step;
  set step(Steps value) => mounted && _step != value ? setState(() => _step = value) : null;
  StepsMachine get _stepState => StepsMachine(current: _step);

  DefaultToolbarActions _tool = DefaultToolbarActions.erase;
  DefaultToolbarActions get tool => _tool;
  set tool(DefaultToolbarActions value) {
    if (mounted && _tool != value) setState(() => _tool = value);
    switch (tool) {
      case DefaultToolbarActions.pen:
        _paintController.freeStyleStrokeWidth = 7;
        _paintController.freeStyleMode = FreeStyleMode.draw;

      case DefaultToolbarActions.erase:
        _paintController.freeStyleStrokeWidth = 7;
        _paintController.freeStyleMode = FreeStyleMode.erase;

      default:
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

  void handleHeartTap() {
    switch (step) {
      case Steps.chooseFace:
        faceIndex++;
        if (faceIndex >= kFaces.length) faceIndex = -1;
        setState(() {});

      case Steps.edit:
        switch (tool) {
          case DefaultToolbarActions.fill:
            heartColorIndex++;
            if (heartColorIndex >= colors.length) heartColorIndex = 0;
            setState(() {});

          default:
        }

      default:
    }
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
            child: GestureDetector(
              onTapDown: (details) => offset = details.localPosition,
              onTap: handleBackgroundTap,
              child: ColorFillAnimation(
                color: colors[heartColorIndex].background,
                offset: offset,
                duration: const Duration(milliseconds: 240),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) => Transform.translate(
                offset: Tween(begin: Offset.zero, end: const Offset(0, 4))
                    .chain(CurveTween(curve: Curves.easeInOut))
                    .animate(_floatingController)
                    .value,
                child: child,
              ),
              child: GestureDetector(
                onTapDown: (details) => offset = details.globalPosition,
                onTap: handleHeartTap,
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
          IgnorePointer(
            ignoring: step != Steps.edit || !{DefaultToolbarActions.pen, DefaultToolbarActions.erase}.contains(tool),
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: 100000,
                height: 100000,
                child: FlutterPainter(
                  controller: _paintController,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: Offset(0, step != Steps.edit ? 1 : 0),
              duration: const Duration(milliseconds: 160),
              curve: Curves.ease,
              child: Toolbar(
                selected: tool,
                onSelected: (value) => tool = value,
                colors: paintColors,
                showColors: {DefaultToolbarActions.pen, DefaultToolbarActions.erase}.contains(tool),
                selectedColor: selectedPaintColor,
                onColorSelected: (index) => selectedPaintColor = index,
                actions:
                    DefaultToolbarActions.values.map((e) => ToolbarActionData(value: e, child: e.build())).toList(),
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
                    GestureDetector(
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
                    GestureDetector(
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
          )
        ],
      ),
    );
  }
}
