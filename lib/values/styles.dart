import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:panamera_app/main.dart';
import 'package:panamera_app/values/colors.dart';

ThemeData buildThemeData(MyApp myApp, bool isDark) {
  final spacing = 0.0;
  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: isDark ? MColors.black : MColors.white,
    indicatorColor: isDark ? MColors.white : MColors.black,
    hintColor: isDark ? MColors.btnNegative : MColors.negative,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? MColors.black : MColors.white,
      surfaceTintColor: isDark ? MColors.black : MColors.white,
      titleTextStyle: TextStyle(color: isDark ? MColors.white : MColors.black, fontSize: 17),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(fontSize: 12, color: isDark ? MColors.white : MColors.black, letterSpacing: spacing),
      bodyMedium: TextStyle(fontSize: 14, color: isDark ? MColors.white : MColors.black, letterSpacing: spacing),
      bodyLarge: TextStyle(fontSize: 16, color: isDark ? MColors.white : MColors.black, fontWeight: FontWeight.bold, letterSpacing: spacing),
      displaySmall: TextStyle(fontSize: 20, color: isDark ? MColors.white : MColors.black, letterSpacing: spacing),
      displayMedium: TextStyle(fontSize: 32, color: isDark ? MColors.white : MColors.black, fontWeight: FontWeight.bold, letterSpacing: spacing),
      displayLarge: TextStyle(fontSize: 40, color: isDark ? MColors.white : MColors.black, fontWeight: FontWeight.bold, letterSpacing: spacing),
      titleSmall: TextStyle(fontSize: 24, color: isDark ? MColors.white : MColors.black, fontWeight: FontWeight.bold, letterSpacing: spacing),
    ),
    cardColor: isDark ? MColors.white.withValues(alpha: 0.1) : MColors.black.withValues(alpha: 0.1),
    fontFamily: 'Inter',
    primaryColor: MColors.primaryGreen,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isDark ? MColors.white : MColors.black,
      selectionHandleColor: isDark ? MColors.white : MColors.black,
    ),
    // tooltipTheme: const TooltipThemeData(preferBelow: false , height: 10),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PageTransition(type: PageTransitionType.fade, child: myApp).matchingBuilder,
        TargetPlatform.iOS: PageTransition(type: PageTransitionType.fade, child: myApp).matchingBuilder,
      },
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: MColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      position: PopupMenuPosition.under,
      elevation: 6,
    ),
    useMaterial3: true,
  );
}
