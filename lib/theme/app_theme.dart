import 'package:flutter/material.dart';
import 'package:transport_flutter/theme/theme.dart';

class AppTheme {
  static final themeData = ThemeData(
      primarySwatch: Colors.indigo,
      primaryColor: Color.fromRGBO(36, 79, 78, 1),
      fontFamily: "Poppins",
      cardTheme: CardTheme(elevation: 0),
      dialogTheme: DialogTheme(elevation: 0),
      appBarTheme: AppBarTheme(elevation: 0, iconTheme: IconThemeData(color: AppColors.green244F4E)),
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        headline4: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        headline5: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
        headline6: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        bodyText1: TextStyle(fontSize: 18.0, height: 1.5),
        bodyText2: TextStyle(fontSize: 15.0),
        subtitle1: TextStyle(fontSize: 16, height: 20 / 16),
        subtitle2: TextStyle(fontSize: 14, height: 17.5 / 14),
      ));
}
