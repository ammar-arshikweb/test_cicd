import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/values/colors.dart';

enum DialogType { RED, GREEN, NEUTRAL }

Future<void> confirmationDialog(
  BuildContext context,
  String icon,
  String subText,
  String yesButton,
  DialogType dialogType,
  VoidCallback onTapCallback,
) async {
  Color dialogColor;
  switch (dialogType) {
    case DialogType.GREEN:
      dialogColor = MColors.green;
      break;
    case DialogType.NEUTRAL:
      dialogColor = MColors.primaryGreen;
      break;
    case DialogType.RED:
      dialogColor = MColors.red;
  }

  var value = await showGeneralDialog<void>(
    context: context,
    barrierLabel: '',
    barrierColor: MColors.black.withValues(alpha: 0.5),
    barrierDismissible: false,
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth * 0.85;

            return Align(
              alignment: Alignment.center,
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Material(
                  color: MColors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Wrap(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: dialogColor.withValues(alpha: 0.1),
                              radius: 45,
                              child: SvgPicture.asset(icon, height: 40, width: 40, colorFilter: ColorFilter.mode(dialogColor, BlendMode.srcIn)),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                subText,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop(false)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MColors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      Helper.getLocalization()!.cancel,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => GlobalTap.safeTap(onTapCallback),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: dialogColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      yesButton,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );

  FocusScope.of(context).unfocus();
  return value;
}

simpleConfirmationDialog({required BuildContext context, required String title, required AppLocalizations strings, required VoidCallback onConfirm}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: MColors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Center(
          child: Dialog(
            backgroundColor: MColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: MColors.dialogText),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => GlobalTap.safeTap(() => Navigator.pop(context)),
                          child: Text(strings.no, style: TextStyle(fontSize: 16, color: MColors.black)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          onPressed: () => GlobalTap.safeTap(onConfirm),
                          child: Text(strings.yes, style: const TextStyle(color: MColors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

comingSoonDialog({required BuildContext context}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: MColors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) {
      return Center(
        child: Dialog(
          backgroundColor: MColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(Assets.images.comingSoon, height: 150, width: 150),
                const SizedBox(height: 30),
                Text(
                  Helper.getLocalization()!.coming_soon_text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, color: MColors.dialogText),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
