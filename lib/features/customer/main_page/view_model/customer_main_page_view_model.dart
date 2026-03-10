import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/main_page/repository/customer_main_page_repo.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/features/employee/main_page/model/logout_model/logout_req.dart';
import 'package:panamera_app/features/employee/main_page/repository/main_page_repo.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/main.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/app_tracking_transparancy.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class CustomerMainPageViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<ServiceStatus>? locationStatusStream;

  initModel(BuildContext context) async {
    if (Platform.isIOS) {
      // Request ATT first
      await AppTrackTransparency.requestTrackingAfterLogin();
      await Future.delayed(const Duration(milliseconds: 600));
    }

    // Request location permission before starting the listener
    await Geolocator.requestPermission();

    // Start listening after permission is granted
    startListeningToLocationService();

    setupFirebaseMessaging(context);
  }

  resetModel() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();
    locationStatusStream?.cancel();
    selectedIndex = 0; // Reset to default index
  }

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void startListeningToLocationService() {
    locationStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        Log.e("Location services are turned ON");
      } else if (status == ServiceStatus.disabled) {
        Log.e("Location services are turned OFF");
      }
    });
  }

  void setupFirebaseMessaging(BuildContext context) async {
    // Request permission (mainly for iOS)
    await _firebaseMessaging.requestPermission();

    // Ensure only one active subscription
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();

    setupFCMTokenSync();

    Log.e("Setting up Firebase Messaging...");

    // Foreground messages
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.e("Foreground message received: ${message.notification?.title}");
      _handleMessage(message, context);
    });

    // Background/tapped messages
    _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.e("Notification opened from background: ${message.notification?.title}");
      _handleMessage(message, context);
    });

    // Cold start
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Log.e("App opened via notification (cold start): ${initialMessage.notification?.title}");
      _handleMessage(initialMessage, context);
    }
  }

  Future<void> setupFCMTokenSync() async {
    final currentToken = await _firebaseMessaging.getToken();
    Log.e("Current FCM Token: $currentToken");
    final storedToken = Pref.getFcmToken();

    if (currentToken != null && currentToken != storedToken) {
      await CustomerMainPageRepo().customerStoreFCMToken(fcmToken: currentToken);
      Pref.setFcmToken(currentToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await CustomerMainPageRepo().customerStoreFCMToken(fcmToken: newToken);
      Pref.setFcmToken(newToken);
    });
  }

  void _handleMessage(RemoteMessage message, BuildContext context) {
    final currentContext = navigatorKey.currentContext;

    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    var data = message.data;
    Log.e("Handling message: $title, $body, Data: ${data.toString()}");

    String notificationType = data[Constant.notificationType] ?? '';
    String notificationId = data[Constant.notificationId] ?? '';

    if (notificationType.isEmpty) {
      Log.e("Notification type is empty, cannot handle message");
    } else if (notificationType == Constant.overtime_request || notificationType == Constant.early_request) {
      Provider.of<AttendanceViewModel>(currentContext ?? context, listen: false).setTabControllerIndexForNotification(context, 1);
    } else if (notificationType == Constant.check_out_reminder) {
      Provider.of<AttendanceViewModel>(currentContext ?? context, listen: false).setTabControllerIndexForNotification(context, 0);
    }

    if (title.isEmpty || body.isEmpty || data.isEmpty) {
      Log.e("Notification title and body are empty, cannot show dialog");
      return;
    }

    // Example action: show a dialog
    showDialog(
      context: currentContext ?? context,
      barrierDismissible: false,
      builder:
          (_) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Center(
              child: Dialog(
                backgroundColor: MColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(body, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          onPressed: () => GlobalTap.safeTap(() => notificationOkBtnClick(currentContext ?? context, notificationId)),
                          child: Text(AppLocalizations.of(currentContext ?? context)?.close ?? '', style: const TextStyle(color: MColors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void notificationOkBtnClick(BuildContext context, String notificationId) {
    if (notificationId.isNotEmpty) {
      MainPageRepo()
          .markNotificationsRead(notificationIds: [int.parse(notificationId)])
          .then((apiRes) {
            if (apiRes.successMessage != null) {
              // Optional: Show success if needed
            } else {
              Log.e('Error notificationOkBtnClick : ${apiRes.errorMessage ?? 'Unknown error'}');
            }
          })
          .catchError((error) {
            Log.e('Error notificationOkBtnClick: $error');
          });
    }
    Navigator.of(context).pop();
  }

  Future<void> logoutButtonClick(BuildContext context) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }

    LogoutReq logoutReq = LogoutReq(refreshToken: Pref.getRefreshToken());

    try {
      context.showLoader();
      final apiRes = await CustomerMainPageRepo().logOut(logoutReq: logoutReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.successMessage != null && context.mounted) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
        Pref.clearAllPreferences();
        Navigator.pushNamedAndRemoveUntil(context, Constant.loginScreen, (route) => false);
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()?.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error during logout: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
