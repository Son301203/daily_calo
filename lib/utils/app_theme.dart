import 'package:flutter/material.dart';

extension AppTheme on ThemeData {
  TextStyle get headerText => const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );

  TextStyle get subHeaderText => const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Roboto',
      );

  TextStyle get bodyText => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );

  TextStyle get smallText => const TextStyle(
        fontSize: 14,
        fontFamily: 'Roboto',
      );

  TextStyle get nutrientText => const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Roboto',
      );

  TextStyle get calorieText => const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );
}