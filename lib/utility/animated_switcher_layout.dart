// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

typedef _LayoutBuilder = Widget Function(Widget? currentChild, List<Widget> previousChildren);

/// Animated Switcher Layout used for [AnimatedSwitcher.layoutBuilder].
///
/// This widget exposes special factory method [builder] to use with [AnimatedSwitcher.layoutBuilder].
///
/// Example:
///
/// ```dart
/// return AnimatedSwitcher(
///   layoutBuilder: AnimatedSwitcherLayout.builder(fit: StackFit.expand),
///   duration: 240.milliseconds,
///   child: frame == null
///       ? const SizedBox.expand(child: IGShimmer(child: Block()))
///       : child,
/// );
/// ```
class AnimatedSwitcherLayout extends StatelessWidget {
  final StackFit fit;
  final AlignmentGeometry alignment;
  final bool ignorePreviousChildrenSize;
  final Clip clipBehavior;

  final List<Widget> previousChildren;
  final Widget? currentChild;

  const AnimatedSwitcherLayout({
    Key? key,
    this.fit = StackFit.loose,
    this.alignment = AlignmentDirectional.topStart,
    this.previousChildren = const [],
    this.currentChild,
    this.ignorePreviousChildrenSize = false,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  static _LayoutBuilder builder({
    Key? key,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    bool ignorePreviousChildrenSize = false,
  }) =>
      (currentChild, previousChildren) => AnimatedSwitcherLayout(
            key: key,
            fit: fit,
            alignment: alignment,
            clipBehavior: clipBehavior,
            ignorePreviousChildrenSize: ignorePreviousChildrenSize,
            previousChildren: previousChildren,
            currentChild: currentChild,
          );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: fit,
      alignment: alignment,
      clipBehavior: clipBehavior,
      children: [
        ...previousChildren.map(
          (e) => ignorePreviousChildrenSize
              ? Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: e,
                )
              : e,
        ),
        if (currentChild != null) currentChild!,
      ],
    );
  }
}
