import 'package:flutter/material.dart';

class AppMediaQuerry {
  static MediaQueryData? _mediaQueryData;

  static MediaQueryData get mq => _mediaQueryData!;

  static void setMq(BuildContext context) {
    if (_mediaQueryData == null) {
      _mediaQueryData = MediaQuery.of(context);
      print("yup");
    }
  }
}
