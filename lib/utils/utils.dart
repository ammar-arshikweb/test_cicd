import 'package:package_info_plus/package_info_plus.dart';
import 'package:panamera_app/utils/time_utils.dart';

class Utils {
  // This function is use for getting app version.
  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static String getGreetingBasedOnTime() {
    final hour = TimeUtils.getCurrentDateTime().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
