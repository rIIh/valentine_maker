import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

class ColorFillAnimation extends StatefulWidget {
  final Color color;
  final Offset? offset;
  final Duration duration;
  final Curve curve;

  const ColorFillAnimation({
    super.key,
    required this.color,
    required this.duration,
    this.offset,
    this.curve = Curves.linear,
  });

  @override
  State<ColorFillAnimation> createState() => _ColorFillAnimationState();
}

class _ColorFillAnimationState extends State<ColorFillAnimation> with TickerProviderStateMixin {
  late GlobalKey active = GlobalKey();
  late List<(Color, Offset?, GlobalKey)> history = [(widget.color, widget.offset, active)];
  late final Map<GlobalKey, AnimationController> _controllers = {};

  @override
  void didUpdateWidget(covariant ColorFillAnimation oldWidget) {
    if (widget.color != oldWidget.color) {
      history.add((widget.color, widget.offset, active = GlobalKey()));
      clear();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controllers.forEach((key, value) => value.dispose());
    _controllers.clear();
    history.clear();
    super.dispose();
  }

  void clear() {
    final toRemove = [];
    for (final (index, item) in history.indexed) {
      final controller = _controllers[item.$3];
      if (controller == null) return;

      if (controller.isCompleted && index < history.length - 2) {
        toRemove.add(item);
      }
    }

    for (final item in toRemove) {
      final controller = _controllers[item.$3]!;
      history.remove(item);
      controller.dispose();
      _controllers.remove(item.$3);
    }

    setState(() {});
  }

  AnimationController createController() {
    final controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    if (history.length == 1) controller.value = 1;

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        clear();
      }
    });

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final item in history)
          AnimatedBuilder(
            key: item.$3,
            animation: _controllers.putIfAbsent(
              item.$3,
              () => createController(),
            ),
            builder: (context, child) {
              final animation = _controllers[item.$3];
              if (animation == null) return const SizedBox();

              return ClipPath(
                clipper: _Clipper(
                  animation.value,
                  offset: item.$2,
                ),
                child: child,
              );
            },
            child: SizedBox.expand(child: ColoredBox(color: item.$1)),
          )
      ],
    );
  }
}

class _Clipper extends CustomClipper<Path> {
  final double value;
  final Offset? offset;

  const _Clipper(this.value, {this.offset});

  @override
  Path getClip(Size size) {
    final xFactor = offset != null ? 1 + ((offset!.dx - size.width / 2) / (size.width / 2)).abs() : 1;
    final yFactor = offset != null ? 1 + ((offset!.dy - size.height / 2) / (size.height / 2)).abs() : 1;
    final diagonal = sqrt(pow(size.width * xFactor, 2) + pow(size.height * yFactor, 2));

    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: offset ?? Offset(size.width / 2, size.height / 2),
          width: diagonal * value,
          height: diagonal * value,
        ),
      );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is! _Clipper || oldClipper.value != value || oldClipper.offset != offset;
  }
}

class ValueCurve extends Curve {
  final double value;

  const ValueCurve(this.value) : assert(value >= 0 && value <= 1);

  @override
  double transformInternal(double t) {
    return value;
  }
}
