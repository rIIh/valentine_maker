import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:valentine/router.dart';
import 'package:valentine/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: kRouter,
      title: 'Valentine Maker',
      debugShowCheckedModeBanner: false,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [],
        child: child!,
      ),
    );
  }
}
