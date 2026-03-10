import 'package:flutter/material.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/main.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/values/colors.dart';

class SnackBarMsg {
  static OverlayEntry? previousOverlayEntry;
  static final bottomPadding = MediaQuery.of(navigatorKey.currentState!.context).padding.bottom;

  static void showSuccessMessage(BuildContext context, String? message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 10 + bottomPadding, // Add system navigation bar padding
            left: 10,
            right: 10,
            child: Material(
              color: MColors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(color: MColors.snackbarBack, borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.images.success),
                    const SizedBox(width: 10),
                    Expanded(child: Text(message!, style: const TextStyle(fontSize: 16, color: MColors.white))),
                  ],
                ),
              ),
            ),
          ),
    );

    // Insert the Snackbar above the dialog
    overlay.insert(overlayEntry);

    // Remove the Snackbar after a delay (to simulate Snackbar duration)
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static void showWarningMessages(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: const BoxDecoration(color: MColors.snackbarBack, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              SvgPicture.asset(Assets.images.error), // Make sure to provide the correct image path
              const SizedBox(width: 10),
              Expanded(child: Text(message, style: const TextStyle(fontSize: 16, color: MColors.white))),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: MColors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(bottom: bottomPadding, left: 10, right: 10),
      ),
    );
  }

  static void showErrorMessage(BuildContext context, String? message) {
    // Remove previous overlay.
    previousOverlayEntry?.remove();
    previousOverlayEntry = null;

    final overlay = Overlay.of(context);
    late final OverlayEntry overlayEntry; // Declare first

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 10 + bottomPadding, // Add system navigation bar padding
            left: 10,
            right: 10,
            child: Material(
              color: MColors.transparent,
              child: GestureDetector(
                onTap: () => GlobalTap.safeTap(() {
                  overlayEntry.remove();
                  previousOverlayEntry = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(color: MColors.snackbarBack, borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      SvgPicture.asset(Assets.images.error), // Your error icon
                      const SizedBox(width: 10),
                      Expanded(child: Text(message!, style: const TextStyle(fontSize: 16, color: MColors.white))),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    // Insert the Snackbar above the dialog
    previousOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Remove the Snackbar after a delay (to simulate Snackbar duration)
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
      previousOverlayEntry = null;
    });
  }

  static void showError(BuildContext context) {
    // Remove previous overlay.
    previousOverlayEntry?.remove();
    previousOverlayEntry = null;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 10 + bottomPadding, // Add system navigation bar padding
            left: 10,
            right: 10,
            child: Material(
              color: MColors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(color: MColors.snackbarBack, borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.images.error), // Your error icon
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.error_occurred_try_again, style: const TextStyle(fontSize: 16, color: MColors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    // Insert the Snackbar above the dialog
    previousOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Remove the Snackbar after a delay (to simulate Snackbar duration)
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
      previousOverlayEntry = null;
    });
  }

  static void noInternet(BuildContext context) {
    // Remove previous overlay.
    previousOverlayEntry?.remove();
    previousOverlayEntry = null;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 10 + bottomPadding, // Add system navigation bar padding
            left: 10,
            right: 10,
            child: Material(
              color: MColors.transparent,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(color: MColors.snackbarBack, borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  children: [
                    Image.asset(Assets.images.noInternet.path, color: MColors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.no_internet_connection, style: const TextStyle(fontSize: 16, color: MColors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    // Insert the Snackbar above the dialog
    previousOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Remove the Snackbar after a delay (to simulate Snackbar duration)
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
      previousOverlayEntry = null;
    });
  }

  static void scaffoldNoInternetMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          height: 60,
          decoration: const BoxDecoration(color: MColors.snackbarBack, borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              Image.asset(Assets.images.noInternet.path, color: MColors.white), // Make sure to provide the correct image path
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.no_internet_connection, style: const TextStyle(fontSize: 16, color: MColors.white)),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: MColors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(bottom: bottomPadding, left: 10, right: 10),
      ),
    );
  }
}
