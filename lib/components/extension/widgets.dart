import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  // Expand
  Widget get fullWidth => SizedBox(width: double.maxFinite, child: this);
  Widget get fulHeight => SizedBox(height: double.maxFinite, child: this);

  Widget wrapHeight(double amount) => SizedBox(height: amount, child: this);
  Widget wrapWidth(double amount) => SizedBox(width: amount, child: this);
  Widget wrapSize(double height, double width) =>
      SizedBox(width: width, height: height, child: this);
  Widget shadow() => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: this,
      );
}
