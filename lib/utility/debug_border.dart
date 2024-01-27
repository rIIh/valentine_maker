import 'package:flutter/material.dart';
import 'package:valentine/utility/debug_padding.dart';

final _kHelpers = {
  Padding: (child) => DebugPadding(widget: child),
};

/// Debug borders draws outline for child widget.
///
/// If [showDimensions] is true, it will draw dimensions of child widget.
class DebugBorder extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool showDimensions;
  final bool drawDimensionsInside;

  const DebugBorder({
    Key? key,
    required this.child,
    this.showDimensions = false,
    this.color = Colors.red,
    this.drawDimensionsInside = false,
  }) : super(key: key);

  const DebugBorder.dimensions({
    Key? key,
    required this.child,
    this.color = Colors.red,
    this.drawDimensionsInside = false,
  })  : showDimensions = true,
        super(key: key);

  @override
  State<DebugBorder> createState() => _DebugBorderState();
}

class _DebugBorderState extends State<DebugBorder> {
  final GlobalKey _key = GlobalKey();
  Size? childSize;

  @override
  Widget build(BuildContext context) {
    if (widget.showDimensions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (this.childSize != _key.currentContext?.size) {
          setState(() => this.childSize = _key.currentContext?.size);
        }
      });
    }

    final borderedChild = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.color,
          width: 1,
        ),
      ),
      child: KeyedSubtree(
        key: _key,
        child: widget.child,
      ),
    );

    if (!widget.showDimensions) return borderedChild;

    final childSize = this.childSize;

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        borderedChild,
        if (childSize != null && widget.showDimensions) ...[
          if (childSize.width != 0)
            Positioned(
              top: widget.drawDimensionsInside ? 0 : -9,
              child: SizedBox(
                width: childSize.width,
                child: Center(
                  child: FittedBox(
                    child: buildDimensionText(childSize.width),
                  ),
                ),
              ),
            ),
          if (childSize.height != 0)
            Positioned(
              left: childSize.width - (widget.drawDimensionsInside ? 16 : 9),
              child: RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  width: childSize.height,
                  child: Center(
                    child: FittedBox(
                      child: buildDimensionText(childSize.height),
                    ),
                  ),
                ),
              ),
            ),
          if (_kHelpers.containsKey(widget.child.runtimeType))
            Positioned.fill(
              child: _kHelpers[widget.child.runtimeType]!(widget.child),
            ),
        ],
      ],
    );
  }

  Widget buildDimensionText(double dimension) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        child: Text(
          dimension.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: widget.color,
            fontSize: 12,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ),
    );
  }
}

extension DebugBorderExtension on Widget {
  Widget debugBorder({Key? key, Color color = Colors.red, bool showDimensions = false}) {
    return DebugBorder(
      key: key,
      color: color,
      showDimensions: showDimensions,
      child: this,
    );
  }

  Widget debugDimensions({Key? key, Color color = Colors.red}) {
    return debugBorder(key: key, color: color, showDimensions: true);
  }
}
