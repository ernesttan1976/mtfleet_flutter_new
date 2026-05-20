import 'package:flutter/material.dart';

extension SpaceFromIntExtension on int {
  Widget get horizontalSpace => SizedBox(width: this.toDouble());
  Widget get verticalSpace => SizedBox(height: this.toDouble());
}

extension SpaceFromDoubleExtension on double {
  Widget get horizontalSpace => SizedBox(width: this);
  Widget get verticalSpace => SizedBox(height: this);
}
