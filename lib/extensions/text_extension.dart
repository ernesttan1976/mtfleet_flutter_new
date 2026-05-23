import 'package:flutter/material.dart';
import 'package:transport_flutter/theme/theme.dart';

extension TextStyleExtension on TextStyle {
  TextStyle get thin => weight(FontWeight.w100);

  TextStyle get extraLight => weight(FontWeight.w200);

  TextStyle get light => weight(FontWeight.w300);

  TextStyle get regular => weight(FontWeight.w400);

  TextStyle get medium => weight(FontWeight.w500);

  TextStyle get semiBold => weight(FontWeight.w600);

  TextStyle get bold => weight(FontWeight.w700);

  TextStyle get maxWeight => weight(FontWeight.w900);

  TextStyle get italic => fontStyleT(FontStyle.italic);

  TextStyle get normal => fontStyleT(FontStyle.normal);

  TextStyle size(double size) => copyWith(fontSize: size);

  TextStyle textColor(Color v) => copyWith(color: v);

  TextStyle weight(FontWeight v) => copyWith(fontWeight: v);

  TextStyle fontStyleT(FontStyle v) => copyWith(fontStyle: v);

  TextStyle setDecoration(TextDecoration v) => copyWith(decoration: v);

  // TextStyle fontFamilies(String v) => this.copyWith(fontFamily:'cvcv');

  TextStyle letterSpaC(double v) => copyWith(letterSpacing: v);

  TextStyle heightLine(double v) => copyWith(height: v / fontSize!);

  TextStyle get text244F4E => textColor(AppColors.green244F4E);

  TextStyle get textWhite => textColor(Colors.white);

  TextStyle get textBlack => textColor(Colors.black);

  TextStyle get decorationUnderline => setDecoration(TextDecoration.underline);

  TextStyle get letterSpacing0p1 => letterSpaC(0.1);
}
