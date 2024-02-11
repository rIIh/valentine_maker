import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:valentine/firebase_options.dart';
import 'package:valentine/router.dart';
import 'package:valentine/theme/sounds.dart';
import 'package:valentine/theme/theme.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://93f36bd2e378e24a6596d76d036a4406@o493241.ingest.sentry.io/4506648831655936';
      options.tracesSampleRate = kDebugMode ? 0 : 1;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      WidgetsBinding.instance.deferFirstFrame();

      if (kIsWeb || !Platform.isLinux) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        FirebaseAnalytics.instance;
      }

      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> precacheAssets(BuildContext context) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestJson);

    await Future.wait(manifest.keys
        .where((element) => element.endsWith('.png') || element.endsWith('.webp'))
        .map((e) => precacheImage(AssetImage(e), context)));
  }

  @override
  Widget build(BuildContext context) {
    Future.wait([
      precacheAssets(context),
      GoogleFonts.pendingFonts([GoogleFonts.fredoka()]),
      // AudioCache.instance.loadAll(['sounds/click-down.mp3', 'sounds/click-up.mp3']),
      Audio.initialize(),
    ]).catchError((_) => []).then((value) {
      if (!WidgetsBinding.instance.firstFrameRasterized) {
        WidgetsBinding.instance.allowFirstFrame();
      }
    });

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
