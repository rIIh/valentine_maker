import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

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
  final AudioPlayer tapDownPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
  final AudioPlayer tapUpPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  @override
  void dispose() {
    tapDownPlayer.dispose();
    tapUpPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      onTap: widget.onTap,
      child: widget.child,
    );
  }

  Future<void>? _future;
  void handleTapDown(TapDownDetails details) {
    tapDownPlayer.play(AssetSource('sounds/click-down.mp3'), position: Duration.zero);
    _future = Future.delayed(const Duration(milliseconds: 140));
    widget.onTapDown?.call(details);
  }

  void handleTapUp(TapUpDetails details) {
    Future(() async {
      await Future.any<void>([_future ?? Future.value()]);
      tapUpPlayer.play(AssetSource('sounds/click-up.mp3'), position: Duration.zero);
    });

    widget.onTapUp?.call(details);
  }
}
