import 'package:flutter/material.dart';

extension TextThemeLegacy on TextTheme {
  TextStyle? get bodyText1 => bodyLarge;
  TextStyle? get bodyText2 => bodyMedium;
  TextStyle? get headline4 => headlineMedium;
  TextStyle? get headline5 => titleLarge;
  TextStyle? get headline6 => titleMedium;
}
