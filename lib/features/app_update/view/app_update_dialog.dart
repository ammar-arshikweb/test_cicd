import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:panamera_app/features/app_update/model/app_update_model.dart';
import 'package:panamera_app/features/app_update/repo/app_updated_repo.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdatePopupHandler {
  static bool _isDialogShowing = false;

  static Future<void> checkAndShowUpdatePopup(BuildContext context) async {
    try {
      if (_isDialogShowing) {
        Log.e("Update dialog already showing, skipping...");
        return;
      }

      final response = await AppUpdateRepo().getAppUpdate();
      if (response.status == false || response.data == null) return;

      final model = response.data!;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final latestVersion = Platform.isAndroid
          ? model.latestVersion
          : model.latestIosVersion;

      final minSupportedVersion = Platform.isAndroid
          ? model.minSupportedVersion
          : model.minIosVersion;

      Log.e('Current App Version: $currentVersion');
      Log.e('Latest Version: $latestVersion');
      Log.e('Min Supported Version: $minSupportedVersion');

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        final isForceUpdate = _compareVersions(currentVersion, minSupportedVersion) < 0;

        if (!isForceUpdate && !_shouldShowOptionalUpdate()) {
          Log.e("Optional update skipped - 1 hours haven't passed yet");
          return;
        }
        _showUpdateDialog(context, model, isForceUpdate);
      } else {
        Pref.setUpdateLaterClickedTime('');
      }
    } catch (e) {
      Log.e("App update check failed: $e");
    }
  }

  static int _compareVersions(String version1, String version2) {
    List<int> v1 = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2 = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = v1.length > v2.length ? v1.length : v2.length;
    while (v1.length < maxLength) v1.add(0);
    while (v2.length < maxLength) v2.add(0);

    for (int i = 0; i < maxLength; i++) {
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
    }
    return 0;
  }

  static bool _shouldShowOptionalUpdate() {
    final lastPressedTime = Pref.getUpdateLaterClickedTime() ?? '';
    if (lastPressedTime.isEmpty) {
      return true;
    }

    try {
      final lastPressed = DateTime.parse(lastPressedTime);
      final now = DateTime.now();
      final difference = now.difference(lastPressed);

      return difference.inHours >= 1;
    } catch (e) {
      Log.e("Error parsing last pressed time: $e");
      return true;
    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    Log.e('Current Version : $current');
    Log.e('Latest Version : $latest');
    List<int> c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> l = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = c.length > l.length ? c.length : l.length;
    while (c.length < maxLength) c.add(0);
    while (l.length < maxLength) l.add(0);

    for (int i = 0; i < maxLength; i++) {
      if (c[i] < l[i]) return true;
      if (c[i] > l[i]) return false;
    }
    return false;
  }

  // Clicks
  static void _laterButtonClick(BuildContext ctx) {
    Pref.setUpdateLaterClickedTime(DateTime.now().toIso8601String());
    _isDialogShowing = false;
    Navigator.pop(ctx);
  }

  static Future<void> _updateNowButtonClick(BuildContext context, String url) async {
    Navigator.pop(context);

    final uri = Uri.parse(url);

    try {
      bool launched = false;

      // Try Chrome first
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication, webViewConfiguration: const WebViewConfiguration(enableJavaScript: true));

      // If not working, try platformDefault (system chooser)
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        // As a last resort, open inside in-app browser
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }

      if (!launched) {
        SnackBarMsg.showErrorMessage(context, 'Could not launch the update URL.');
      }
    } catch (e) {
      Log.e('Error launching update URL: $e');
      SnackBarMsg.showErrorMessage(context, 'Could not launch the update URL.');
    }
  }

  static void _showUpdateDialog(BuildContext context, AppUpdateModel model, bool isForceUpdate) {
    if (!context.mounted) {
      Log.e("Context not mounted, skipping update dialog");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final url = Platform.isAndroid ? model.androidUrl : model.iosUrl;

    _isDialogShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        _isDialogShowing = false;
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: !isForceUpdate,
        builder: (ctx) {
          return PopScope(
            canPop: !isForceUpdate,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop && !isForceUpdate) {
                _isDialogShowing = false;
              }
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Dialog(
                backgroundColor: MColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenSizeConfig.height * 0.03, horizontal: ScreenSizeConfig.width * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(ScreenSizeConfig.height * 0.02),
                        decoration: BoxDecoration(
                          color: isForceUpdate ? MColors.red.withAlpha(30) : MColors.primaryGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(ScreenSizeConfig.height * 0.05),
                        ),
                        child: Icon(
                          Icons.system_update,
                          size: ScreenSizeConfig.height * 0.05,
                          color: isForceUpdate ? MColors.red : MColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: ScreenSizeConfig.height * 0.02),

                      Text(
                        isForceUpdate ? AppLocalizations.of(context)!.update_required : AppLocalizations.of(context)!.update_available,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: MColors.dialogText),
                      ),
                      SizedBox(height: ScreenSizeConfig.height * 0.015),

                      Text(
                        isForceUpdate
                            ? AppLocalizations.of(context)!.critical_update_message(model.latestVersion)
                            : AppLocalizations.of(context)!.update_available_message(model.latestVersion),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.textDarkGrey, height: 1.5),
                      ),
                      SizedBox(height: ScreenSizeConfig.height * 0.03),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!isForceUpdate)
                            Expanded(
                              child: TextButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(horizontal: ScreenSizeConfig.height * 0.02, vertical: ScreenSizeConfig.height * 0.025),
                                  ),
                                ),
                                onPressed: () => GlobalTap.safeTap(() => _laterButtonClick(ctx)),
                                child: Text(
                                  AppLocalizations.of(context)!.later,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          if (!isForceUpdate) SizedBox(width: ScreenSizeConfig.width * 0.02),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isForceUpdate ? MColors.red : MColors.primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: ScreenSizeConfig.height * 0.02, vertical: ScreenSizeConfig.height * 0.025),
                              ),
                              onPressed: () => GlobalTap.safeTap(() => _updateNowButtonClick(ctx, url)),
                              child: Text(
                                AppLocalizations.of(context)!.update_now,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                              ),
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
      ).then((_) {
        _isDialogShowing = false;
      });
    });
  }
}
