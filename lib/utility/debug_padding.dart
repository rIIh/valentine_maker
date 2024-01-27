import 'package:flutter/material.dart';
import 'package:valentine/utility/debug_border.dart';

class DebugPadding extends StatelessWidget {
  final Padding widget;

  EdgeInsetsGeometry get padding => widget.padding;

  const DebugPadding({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final padding = this.padding.resolve(Directionality.of(context));

    return IgnorePointer(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: widget.padding,
              child: const DebugBorder(
                child: SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: const Alignment(0, -.25),
              child: Center(
                child: SizedBox(
                  width: padding.left,
                ).debugDimensions(),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: const Alignment(0, -.25),
              child: SizedBox(
                width: padding.right,
              ).debugDimensions(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: const Alignment(-.25, 0),
              child: SizedBox(
                height: padding.bottom,
              ).debugDimensions(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: const Alignment(-.25, 0),
              child: SizedBox(
                height: padding.top,
              ).debugDimensions(),
            ),
          ),
        ],
      ),
    );
  }
}
