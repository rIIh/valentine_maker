import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:valentine/theme/theme.dart';

const _kPositions = [
  Alignment(-.6, -.9),
  Alignment(1.05, -.9),
  Alignment(-1, -.5),
  Alignment(.45, -.5),
  Alignment(1.15, -.1),
  Alignment(-1.15, .1),
  Alignment(.6, .2),
  Alignment(-.6, .4),
  Alignment(1.05, .7),
  Alignment(-.95, .9),
  Alignment(.95, 1.05),
  Alignment(.0, .05),
];

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => GoRouter.of(context).push('/make'),
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset('assets/images/onboarding/heart_bottom.png'),
              ),
            ),
          ),
          Center(
            child: MaxWidthBox(
              maxWidth: 800,
              child: Stack(
                children: [
                  for (final index in List.generate(_kPositions.length, (index) => index))
                    Align(alignment: _kPositions[index], child: _FloatingItem(index: index + 1)),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -.25),
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  const TextSpan(text: 'create a\n'),
                  TextSpan(
                    text: 'valentine',
                    style: TextStyle(color: context.appColors.red),
                  )
                ],
                style: context.h1,
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 46),
                child: Text(
                  textAlign: TextAlign.center,
                  style: context.button,
                  'click to continue',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _FloatingItem extends StatefulWidget {
  const _FloatingItem({
    required this.index,
  });

  final int index;

  @override
  State<_FloatingItem> createState() => _FloatingItemState();
}

class _FloatingItemState extends State<_FloatingItem> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  final angle = Random().nextDouble() * pi * 2;
  final threshold = Random().nextDouble() * .25;

  @override
  void initState() {
    _controller.value = Random().nextDouble();
    forward();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _FloatingItem oldWidget) {
    forward();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void forward() {
    _controller.duration = const Duration(seconds: 2);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        angle: angle +
            Tween(begin: -threshold, end: threshold)
                .chain(CurveTween(curve: Curves.easeInOut))
                .animate(_controller)
                .value,
        child: child,
      ),
      child: Image.asset('assets/images/onboarding/floating/${widget.index}.png'),
    );
  }
}
