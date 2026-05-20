import 'package:flutter/material.dart';

extension WidgetPaddingExtension on Widget {
  // Expand
  Widget  paddingHorizontal(double amount) => Padding(padding: EdgeInsets.symmetric(horizontal:amount ), child: this);

  Widget  paddingVertical(double amount) => Padding(padding: EdgeInsets.symmetric(vertical:amount ), child: this);

  Widget  paddingAll(double amount) => Padding(padding: EdgeInsets.all(amount), child: this);

  Widget  paddingFromLTRB(double left,double top,double right,double bottom) => Padding(padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);

  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) =>
      Padding(
          padding: EdgeInsets.only(
              top: top, left: left, right: right, bottom: bottom),
          child: this);
 }