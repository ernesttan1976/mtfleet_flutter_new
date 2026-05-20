import 'package:flutter/material.dart';
import 'package:transport_flutter/theme/theme.dart';

class AppTheme {
  static final themeData = ThemeData(
    primarySwatch: Colors.indigo,
    primaryColor: Color.fromRGBO(36, 79, 78, 1),
    fontFamily: "Poppins",
    appBarTheme: const AppBarTheme(elevation: 0, iconTheme: IconThemeData(color: AppColors.green244F4E)),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 18.0, height: 1.5),
      bodyMedium: TextStyle(fontSize: 15.0),
      titleMedium: TextStyle(fontSize: 16, height: 20 / 16),
      titleSmall: TextStyle(fontSize: 14, height: 17.5 / 14),
    ),
  );
}
