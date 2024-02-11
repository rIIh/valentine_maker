import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
  final AudioPlayer tapDownPlayer = AudioPlayer()..setAsset('sounds/click-down.mp3');
  final AudioPlayer tapUpPlayer = AudioPlayer()..setAsset('sounds/click-up.mp3');

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
    widget.onTapDown?.call(details);
    Future(() async {
      await tapDownPlayer.seek(Duration.zero);
      await tapDownPlayer.play();
      _future = Future.delayed(const Duration(milliseconds: 100));
    });
  }

  void handleTapUp(TapUpDetails details) {
    widget.onTapUp?.call(details);
    Future(() async {
      await Future.wait<void>([
        _future ?? Future.value(),
        if (tapDownPlayer.playerState.playing) tapDownPlayer.playingStream.first,
      ]);
      await tapUpPlayer.seek(Duration.zero);
      tapUpPlayer.play();
    });
  }
}
