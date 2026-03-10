import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/dialog_utils.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/values/colors.dart';

class SplashViewModel with ChangeNotifier {
  late AppLocalizations strings;

  // Dialog state flag
  bool _isDialogShowing = false;

  // This function will call in the intState of stateful widget
  Future<void> initModel({required BuildContext context}) async {
    strings = Helper.getLocalization()!;
    gotoLoginOrDashboardScreen(context: context);
  }

  // This function will call in the build of stateful widget
  Future<void> buildModel({required BuildContext context}) async {}

  // This function will call in the onDispose of stateful widget
  Future<void> resetModel() async {
    _isDialogShowing = false;
  }

  // This function is use for go to login or dashboard screen.
  Future<void> gotoLoginOrDashboardScreen({required BuildContext context}) async {
    if (_isDialogShowing) return; // Prevent multiple dialogs
    Timer(const Duration(seconds: 1), () async {
      if (Pref.getJwt() != null) {
        if (await isAuthenticated(context)) {
          if(Pref.getIsCustomer()){
            Navigator.pushReplacementNamed(context, Constant.customerMainPage);
          }else {
            Navigator.pushReplacementNamed(context, Constant.mainPage);
          }
        } else {
          // SnackBarMsg.showError(context);
        }
      } else {
        Navigator.pushReplacementNamed(context, Constant.loginScreen);
      }
    });
  }

  // This function is use for opening the phone lock and authenticate the user.
  Future<bool> isAuthenticated(BuildContext context) async {
    final LocalAuthentication localAuth = LocalAuthentication();
    bool isAuthenticated = false;
    bool isDeviceSupported = false;
    AppLocalizations strings = Helper.getLocalization()!;

    try {
      isDeviceSupported = await localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      Log.e('Error checking device support: $e');
    }

    if (!isDeviceSupported) {
      Log.e('Device is not supported for biometric authentication');
      return true;
    }

    try {
      _isDialogShowing = true;
      isAuthenticated = await localAuth.authenticate(
        localizedReason: strings.please_authenticate_to_continue,
        options: const AuthenticationOptions(stickyAuth: true, sensitiveTransaction: false),
      );
      _isDialogShowing = false;
    } catch (e) {
      Log.e('Biometric auth error: $e');
      _isDialogShowing = false;
    }

    while (!isAuthenticated) {
      _isDialogShowing = true;
      final retry = await DialogUtils.showConfirmationDialog(
        context: context,
        message: '${strings.authentication_failed}!\n${strings.would_you_like_to_try_again}',
        icon: null,
        positiveButtonText: strings.retry,
        negativeButtonText: strings.cancel,
        mainColor: MColors.red,
        onPositiveButtonClick: () => Navigator.pop(context, true),
        onNegativeButtonClick: () {
          Navigator.pop(context, false);
          _isDialogShowing = false;
        },
      );
      _isDialogShowing = false;
      if (retry == true) {
        try {
          _isDialogShowing = true;
          isAuthenticated = await localAuth.authenticate(
            localizedReason: strings.please_authenticate_to_continue,
            options: const AuthenticationOptions(stickyAuth: true, sensitiveTransaction: false),
          );
          _isDialogShowing = false;
        } catch (e) {
          Log.e('Retry failed: $e');
          _isDialogShowing = false;
        }
      } else {
        _isDialogShowing = false;
        if (Platform.isAndroid) {
          SystemNavigator.pop(); // Close app on Android
        } else if (Platform.isIOS) {
          exit(0); // Caution: not recommended for iOS, but will work
        }
        break;
      }
    }

    return isAuthenticated;
  }
}

// class AuthService {
//   final LocalAuthentication _localAuth = LocalAuthentication();
//
//   Future<bool> authenticateWithBiometrics() async {
//     bool isAuthenticated = false;
//
//     try {
//       isAuthenticated = await _localAuth.authenticate(
//         localizedReason: ' ',
//         options: const AuthenticationOptions(stickyAuth: true, sensitiveTransaction: false),
//       );
//     } catch (e) {
//       print('Error during biometric auth: $e');
//     }
//
//     return isAuthenticated;
//   }
// }
