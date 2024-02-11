import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedConstrainedBox extends ImplicitlyAnimatedWidget {
  final Widget child;
  final Alignment alignment;
  final BoxConstraints constraints;

  const AnimatedConstrainedBox({
    super.key,
    super.curve,
    this.alignment = Alignment.topLeft,
    required this.constraints,
    required super.duration,
    required this.child,
  });

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedConstrainedBoxState();
}

class _AnimatedConstrainedBoxState extends AnimatedWidgetBaseState<AnimatedConstrainedBox> {
  BoxConstraintsTween? _constraints;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _constraints = visitor(
            _constraints, widget.constraints, (dynamic value) => BoxConstraintsTween(begin: value as BoxConstraints))
        as BoxConstraintsTween?;
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minWidth: 0,
      minHeight: 0,
      maxHeight: double.infinity,
      maxWidth: double.infinity,
      alignment: widget.alignment,
      child: ConstrainedBox(
        constraints: _constraints!.evaluate(animation),
        child: widget.child,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<BoxConstraintsTween>('constraints', _constraints, defaultValue: null));
  }
}
