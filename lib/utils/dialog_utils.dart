import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/values/colors.dart';

class DialogUtils {
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String message,
    required String? icon,
    required String positiveButtonText,
    required String negativeButtonText,
    required Color mainColor,
    required Function() onPositiveButtonClick,
    required Function() onNegativeButtonClick,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Dialog(
                backgroundColor: MColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenSizeConfig.height * 0.03,horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: EdgeInsets.all(ScreenSizeConfig.height * 0.02),
                          decoration: BoxDecoration(
                            color: mainColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(ScreenSizeConfig.height * 0.05),
                          ),
                          child: SvgPicture.asset(
                            icon,
                            colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
                            height: ScreenSizeConfig.height * 0.04,
                            width: ScreenSizeConfig.height * 0.04,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(height: ScreenSizeConfig.height * 0.03),
                      ],
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: MColors.black, // Assuming MColors.dialogText is MColors.black
                        ),
                      ),
                      SizedBox(height: ScreenSizeConfig.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => GlobalTap.safeTap(() {
                                onNegativeButtonClick();
                              }),
                              child: Text(
                                negativeButtonText.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: ScreenSizeConfig.height * 0.04, vertical: ScreenSizeConfig.height * 0.02),
                              ),
                              onPressed: () => GlobalTap.safeTap(() {
                                onPositiveButtonClick();
                              }),
                              child: Text(
                                positiveButtonText.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }
}
