import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:valentine/pages/onboarding_page.dart';
import 'package:valentine/pages/valentine_maker_page.dart';

final kRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
          child: child,
        ),
        child: const OnboardingPage(),
      ),
    ),
    GoRoute(
      path: '/make',
      pageBuilder: (context, state) => FadePage(
        key: state.pageKey,
        child: const ValentineMakerPage(),
      ),
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
