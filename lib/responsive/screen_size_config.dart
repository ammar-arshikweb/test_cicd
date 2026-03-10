import 'package:flutter/material.dart';

class ScreenSizeConfig {
  static late double height;
  static late double width;

  // This function is getting screen height and width.
  static void init({required BuildContext context}) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }
}
