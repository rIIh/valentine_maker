import 'package:flutter/widgets.dart';
import 'package:valentine/theme/theme.dart';

class HeartColor {
  final Color background;
  final Color foreground;

  const HeartColor({required this.background, required this.foreground});
}

List<HeartColor> getHeartColors(BuildContext context) {
  return [
    HeartColor(background: context.background, foreground: context.red),
    HeartColor(background: context.background, foreground: context.blue),
    HeartColor(background: context.green, foreground: context.yellow),
    HeartColor(background: context.green, foreground: context.blue),
    HeartColor(background: context.blue, foreground: context.pink),
    HeartColor(background: context.blue, foreground: context.green),
    HeartColor(background: context.yellow, foreground: context.violet),
    HeartColor(background: context.yellow, foreground: context.red),
  ];
}
