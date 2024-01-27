// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast

part of 'theme.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.black,
    required this.blue,
    required this.cyan,
    required this.green,
    required this.pink,
    required this.red,
    required this.text,
    required this.violet,
    required this.white,
    required this.yellow,
  });

  final Color background;
  final Color black;
  final Color blue;
  final Color cyan;
  final Color green;
  final Color pink;
  final Color red;
  final Color text;
  final Color violet;
  final Color white;
  final Color yellow;

  static const AppColors light = AppColors(
    background: Color(0xFFFA9FED),
    black: Colors.black,
    blue: Color(0xFF347AFE),
    cyan: Color(0xFF57F5FF),
    green: Color(0xFF00DEB7),
    pink: Color(0xFFFE82EA),
    red: Color(0xFFFF414D),
    text: Colors.white,
    violet: Color(0xFFCA8FFF),
    white: Colors.white,
    yellow: Color(0xFFFFE264),
  );

  static const themes = [
    light,
  ];

  @override
  AppColors copyWith({
    Color? background,
    Color? black,
    Color? blue,
    Color? cyan,
    Color? green,
    Color? pink,
    Color? red,
    Color? text,
    Color? violet,
    Color? white,
    Color? yellow,
  }) {
    return AppColors(
      background: background ?? this.background,
      black: black ?? this.black,
      blue: blue ?? this.blue,
      cyan: cyan ?? this.cyan,
      green: green ?? this.green,
      pink: pink ?? this.pink,
      red: red ?? this.red,
      text: text ?? this.text,
      violet: violet ?? this.violet,
      white: white ?? this.white,
      yellow: yellow ?? this.yellow,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this as AppColors;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      black: Color.lerp(black, other.black, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      green: Color.lerp(green, other.green, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      red: Color.lerp(red, other.red, t)!,
      text: Color.lerp(text, other.text, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      white: Color.lerp(white, other.white, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppColors &&
            const DeepCollectionEquality()
                .equals(background, other.background) &&
            const DeepCollectionEquality().equals(black, other.black) &&
            const DeepCollectionEquality().equals(blue, other.blue) &&
            const DeepCollectionEquality().equals(cyan, other.cyan) &&
            const DeepCollectionEquality().equals(green, other.green) &&
            const DeepCollectionEquality().equals(pink, other.pink) &&
            const DeepCollectionEquality().equals(red, other.red) &&
            const DeepCollectionEquality().equals(text, other.text) &&
            const DeepCollectionEquality().equals(violet, other.violet) &&
            const DeepCollectionEquality().equals(white, other.white) &&
            const DeepCollectionEquality().equals(yellow, other.yellow));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(background),
      const DeepCollectionEquality().hash(black),
      const DeepCollectionEquality().hash(blue),
      const DeepCollectionEquality().hash(cyan),
      const DeepCollectionEquality().hash(green),
      const DeepCollectionEquality().hash(pink),
      const DeepCollectionEquality().hash(red),
      const DeepCollectionEquality().hash(text),
      const DeepCollectionEquality().hash(violet),
      const DeepCollectionEquality().hash(white),
      const DeepCollectionEquality().hash(yellow),
    );
  }
}

extension AppColorsBuildContextProps on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  Color get background => appColors.background;
  Color get black => appColors.black;
  Color get blue => appColors.blue;
  Color get cyan => appColors.cyan;
  Color get green => appColors.green;
  Color get pink => appColors.pink;
  Color get red => appColors.red;
  Color get text => appColors.text;
  Color get violet => appColors.violet;
  Color get white => appColors.white;
  Color get yellow => appColors.yellow;
}

class AppStyles extends ThemeExtension<AppStyles> {
  const AppStyles({
    required this.button,
    required this.h1,
  });

  final TextStyle button;
  final TextStyle h1;

  static final AppStyles core = AppStyles(
    button: _$AppStyles.button[0],
    h1: _$AppStyles.h1[0],
  );

  static final themes = [
    core,
  ];

  @override
  AppStyles copyWith({
    TextStyle? button,
    TextStyle? h1,
  }) {
    return AppStyles(
      button: button ?? this.button,
      h1: h1 ?? this.h1,
    );
  }

  @override
  AppStyles lerp(covariant ThemeExtension<AppStyles>? other, double t) {
    if (other is! AppStyles) return this as AppStyles;
    return AppStyles(
      button: TextStyle.lerp(button, other.button, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppStyles &&
            const DeepCollectionEquality().equals(button, other.button) &&
            const DeepCollectionEquality().equals(h1, other.h1));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(button),
      const DeepCollectionEquality().hash(h1),
    );
  }
}

extension AppStylesBuildContextProps on BuildContext {
  AppStyles get appStyles => Theme.of(this).extension<AppStyles>()!;
  TextStyle get button => appStyles.button;
  TextStyle get h1 => appStyles.h1;
}
