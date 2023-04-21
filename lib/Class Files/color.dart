import 'package:flutter/material.dart';

class AColor {
  static const Color themeColor = Color(0xff4B7EF7);

  static const Color backgroundColor = Color(0XFFF1F1F1);

  static const Color white = Color(0XFFFFFFFF);

  static const Color black = Color(0XFF000000);

  static const Color seen = Color(0XFF1DA7EF);

  static const Color send = Color(0XFF2DB83D);

  static const Color mainColor = Color(0xFF177767);

  static const Color grey = Color(0XFF808080);

  static const Color warn = Color(0XB3FF0000);

  static const Color success = Color(0X9900FF00);

  static const Color yellowWarn = Color(0X99FFFF00);

  static const Color infoBgColor = Color(0XFF33b5e5);

  static const LinearGradient buttonGradientShader = LinearGradient(
    colors: [
      Color(0xff1DCEE2),
      Color(0xff4B7EF7),
    ],
    stops: [0, 1],
    begin: AlignmentDirectional(0.6, 0),
    end: AlignmentDirectional(-1, 1),
  );
}
