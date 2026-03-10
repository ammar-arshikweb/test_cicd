import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/values/colors.dart';

/// Dynamic System UI Manager for handling status bar styling
class SystemUIManager {

  /// Set system UI with dynamic status bar color
  /// If statusBarColor is not provided, defaults to white in light mode and black in dark mode
  static void setSystemUI({
    required BuildContext context,
    Color? statusBarColor,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      // Get theme information
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      // Use provided color or default based on theme
      final Color effectiveStatusBarColor = statusBarColor ?? MColors.transparent;
      // String hexCode = '#'
      //     '${effectiveStatusBarColor.alpha.toRadixString(16).padLeft(2, '0')}'
      //     '${effectiveStatusBarColor.red.toRadixString(16).padLeft(2, '0')}'
      //     '${effectiveStatusBarColor.green.toRadixString(16).padLeft(2, '0')}'
      //     '${effectiveStatusBarColor.blue.toRadixString(16).padLeft(2, '0')}'
      //     .toUpperCase();
      //
      // Log.e('Effective Status Bar Color HEX: $hexCode');
      // Calculate brightness based on color luminance
      final double luminance = effectiveStatusBarColor.computeLuminance();

      // Determine icon brightness (light icons on dark background, dark icons on light background)
      final Brightness iconBrightness = luminance > 0.5 ? Brightness.dark : Brightness.light;

      if(!Platform.isIOS){
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: effectiveStatusBarColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: MColors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        );
      }
    });
  }
}
