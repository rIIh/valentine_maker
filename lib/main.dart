import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:valentine/router.dart';
import 'package:valentine/theme/theme.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://93f36bd2e378e24a6596d76d036a4406@o493241.ingest.sentry.io/4506648831655936';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
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
