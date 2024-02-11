// ignore_for_file: unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'theme.tailor.dart';

@Tailor(themes: ['light'])
class _$AppColors {
  static const List<Color> background = [Color(0xFFFA9FED)];
  static const List<Color> text = [Colors.white];

  static const List<Color> blue = [Color(0xFF347AFE)];
  static const List<Color> green = [Color(0xFF00DEB7)];
  static const List<Color> pink = [Color(0xFFFE82EA)];
  static const List<Color> red = [Color(0xFFFF414D)];
  static const List<Color> violet = [Color(0xFFCA8FFF)];
  static const cyan = [Color(0xFF57F5FF)];
  static const List<Color> yellow = [Color(0xFFFFE264)];

  static const List<Color> white = [Colors.white];
  static const List<Color> black = [Colors.black];
}

@Tailor(themes: ['core'])
class _$AppStyles {
  static const _kFontFamily = GoogleFonts.fredoka;

  static final List<TextStyle> h1 = [_kFontFamily(fontSize: 50, height: 62 / 50, fontWeight: FontWeight.w600)];
  static final List<TextStyle> button = [_kFontFamily(fontSize: 20, height: 24 / 20, fontWeight: FontWeight.w600)];
}

final kLightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.light.background,
  ),
  textTheme: ThemeData().textTheme.apply(
        bodyColor: AppColors.light.text,
        displayColor: AppColors.light.text,
      ),
  extensions: [
    AppColors.light,
    AppStyles.core,
  ],
  useMaterial3: true,
);

final kDarkTheme = ThemeData.dark(
  useMaterial3: true,
).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.light.background,
  ),
  textTheme: ThemeData().textTheme.apply(
        bodyColor: AppColors.light.text,
        displayColor: AppColors.light.text,
      ),
  extensions: [
    AppColors.light,
    AppStyles.core,
  ],
);
