import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Scale {
  final double value;

  const Scale(this.value);
}

class ResponsiveScaledBoxPixelRatioFix extends StatefulWidget {
  final double? width;
  final Widget child;
  final bool autoCalculateMediaQueryData;

  const ResponsiveScaledBoxPixelRatioFix({
    super.key,
    this.width,
    this.autoCalculateMediaQueryData = true,
    required this.child,
  });

  @override
  State<ResponsiveScaledBoxPixelRatioFix> createState() => _ResponsiveScaledBoxPixelRatioFixState();
}

class _ResponsiveScaledBoxPixelRatioFixState extends State<ResponsiveScaledBoxPixelRatioFix> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveValue<double>(
      context,
      conditionalValues: [
        Condition.smallerThan(breakpoint: 375, value: 375),
        Condition.largerThan(breakpoint: 1920, value: 1920),
      ],
    ).value;

    final scale = width != null ? MediaQuery.sizeOf(context).width / width : 1.0;

    return ResponsiveScaledBox(
      width: widget.width,
      autoCalculateMediaQueryData: widget.autoCalculateMediaQueryData,
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(devicePixelRatio: scale * MediaQuery.of(context).devicePixelRatio),
          child: KeyedSubtree(
            key: _key,
            child: Provider.value(
              value: Scale(scale),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
