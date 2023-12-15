import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppStyle {
  static Color primaryColor = Color.fromARGB(255, 28, 31, 51);
  static Color primaryColorDark = const Color(0xFF193bb1);

  /* Definining text style */
  static TextStyle mainText = const TextStyle(
    color: Colors.black,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle mainTextWhite = const TextStyle(
    color: Colors.white,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle mainTextThin = const TextStyle(
    color: Colors.black87,
    fontSize: 32.0,
    fontWeight: FontWeight.w200,
  );

  static TextStyle mainTextThinWhite = const TextStyle(
    color: Colors.white60,
    fontSize: 32.0,
    fontWeight: FontWeight.w200,
  );
}
