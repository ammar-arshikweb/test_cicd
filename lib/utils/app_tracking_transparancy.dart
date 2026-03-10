import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';

class AppTrackTransparency {

  static Future<void> requestTrackingAfterLogin() async {
    Log.e('App Tracking popup requested');
    final alreadyRequested = Pref.getAppTracking() ?? false;
    Log.e('alreadyRequested $alreadyRequested');

    if (!alreadyRequested) {
      await Future.delayed(const Duration(milliseconds: 600));

      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        Log.e('ATT REQUESTED');
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
      Pref.setAppTracking(true);
    }
  }
}