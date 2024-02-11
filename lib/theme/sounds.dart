import 'package:audioplayers/audioplayers.dart';

class Audio {
  static late final AudioPool _clickDown;
  static late final AudioPool _clickUp;
  static late final AudioPool _camera;
  static bool _initiliazed = false;
  bool get initialized => _initiliazed;

  static Future? _initializing;
  static Future<void> initialize() {
    return _initializing ??= Future(() async {
      try {
        final <AudioPool>[clickDown, clickUp, camera] = await Future.wait([
          AudioPool.create(source: AssetSource('sounds/click-down.mp3'), maxPlayers: 4),
          AudioPool.create(source: AssetSource('sounds/click-up.mp3'), maxPlayers: 4),
          AudioPool.create(source: AssetSource('sounds/camera.mp3'), maxPlayers: 1),
        ]);

        _clickDown = clickDown;
        _clickUp = clickUp;
        _camera = camera;
      } finally {
        _initiliazed = true;
      }
    });
  }

  static void clickDown() => _clickDown.start();
  static void clickUp() => _clickUp.start();
  static void camera() => _camera.start();
}
