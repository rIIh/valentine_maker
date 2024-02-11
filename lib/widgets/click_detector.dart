import 'package:flutter/material.dart';
import 'package:valentine/theme/sounds.dart';

class ClickDetector extends StatefulWidget {
  final HitTestBehavior? behavior;

  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final Widget? child;

  const ClickDetector({
    super.key,
    this.behavior,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    required this.child,
  });

  @override
  State<ClickDetector> createState() => _ClickDetectorState();
}

class _ClickDetectorState extends State<ClickDetector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: handleTapDown,
      onTap: widget.onTap != null
          ? () {
              Audio.clickUp();
              widget.onTap!();
            }
          : null,
      child: widget.child,
    );
  }

  void handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;

    widget.onTapDown?.call(details);
    Audio.clickDown();
  }
}
