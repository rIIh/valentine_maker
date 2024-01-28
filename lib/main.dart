import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:valentine/firebase_options.dart';
import 'package:valentine/router.dart';
import 'package:valentine/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || !Platform.isLinux) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAnalytics.instance;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://93f36bd2e378e24a6596d76d036a4406@o493241.ingest.sentry.io/4506648831655936';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
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
