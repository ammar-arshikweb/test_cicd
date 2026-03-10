import 'dart:async';
import 'package:flutter/material.dart';

class GlobalTap {
  static bool _locked = false;

  static void safeTap(VoidCallback onTap, {int ms = 500}) {
    if (_locked) return;
    _locked = true;

    onTap();

    Future.delayed(Duration(milliseconds: ms), () {
      _locked = false;
    });
  }
}
