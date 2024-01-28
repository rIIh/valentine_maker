import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:valentine/pages/onboarding_page.dart';
import 'package:valentine/pages/share_page.dart';
import 'package:valentine/pages/valentine_maker_page.dart';
import 'package:valentine/theme/theme.dart';

final kRouter = GoRouter(
  observers: [
    if (kIsWeb || !Platform.isLinux) FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
          child: child,
        ),
        child: const Responsive(child: OnboardingPage()),
      ),
    ),
    GoRoute(
      path: '/make',
      pageBuilder: (context, state) {
        return FadePage(
          key: state.pageKey,
          child: const Responsive(child: ValentineMakerPage()),
        );
      },
    ),
    GoRoute(
      path: '/share',
      // redirect: (context, state) => state.extra == null || state.extra is! ShareTemplate ? '/' : null,
      pageBuilder: (context, state) {
        final extras = state.extra as ShareTemplate;

        return FlashPage(
          key: state.pageKey,
          child: Responsive(child: SharePage(template: extras)),
        );
      },
    ),
  ],
);

class FadePage<T> extends CustomTransitionPage<T> {
  const FadePage({required super.child, required super.key}) : super(transitionsBuilder: transition);

  static Widget transition(context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
      child: child,
    );
  }
}

class FlashPage<T> extends CustomTransitionPage<T> {
  const FlashPage({required super.child, required super.key}) : super(transitionsBuilder: transition);

  static Widget transition(context, Animation<double> animation, secondaryAnimation, child) {
    if (animation.status == AnimationStatus.reverse) {
      return FadePage.transition(context, animation, secondaryAnimation, child);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.white.withOpacity(
            TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeIn)),
                weight: .5,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeIn)),
                weight: .5,
              ),
            ]).animate(animation).value,
          ),
        ),
        position: DecorationPosition.foreground,
        child: child,
      ),
      child: FadeTransition(
        opacity: CurveTween(curve: const Interval(.5, .5, curve: Curves.fastOutSlowIn)).animate(animation),
        child: child,
      ),
    );
  }
}

class Responsive extends StatefulWidget {
  final Widget child;

  const Responsive({super.key, required this.child});

  @override
  State<Responsive> createState() => _ResponsiveState();
}

class _ResponsiveState extends State<Responsive> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaledBox(
      width: ResponsiveValue<double>(
        context,
        conditionalValues: [
          Condition.smallerThan(breakpoint: 375, value: 375),
          Condition.largerThan(breakpoint: 1920, value: 1920),
        ],
      ).value,
      child: KeyedSubtree(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
