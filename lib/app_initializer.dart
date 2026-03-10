import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:panamera_app/main.dart';
import 'package:panamera_app/services/database_service.dart';
import 'package:panamera_app/services/environment_repo.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';

class AppInitializer {
  static PackageInfo? packageInfo;
  static String? osInfo;

  static Future<void> initialize() async {
    await DatabaseService.initialize();
    await Firebase.initializeApp();
    await Pref.initialize();
    NetworkStatusService();
    await getAppVersion();
    getDeviceModel();
    if (!isLive) {
      await getEnvironmentUrl();
    }
  }

  static Future<void> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    packageInfo = info;
  }

  static void getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      osInfo = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      osInfo = iosInfo.utsname.machine;
    }
  }

  static Future<void> getEnvironmentUrl() async {
    Log.e('Fetching environment URLs...');
    try {
      final response = await EnvironmentRepo().getEnvironmentUrls();
      if (response.status == true && response.data != null) {
        final urls = response.data!;
        await Pref.setEnvironmentUrls(urls);
        Log.i(
          'Environment URLs fetched and stored successfully. '
              'Production: ${urls.production}, Development: ${urls.development}, Local: ${urls.local}',
        );
      } else {
        Log.e('Failed to fetch environment URLs: ${response.errorMessage}');
      }
    } catch (e) {
      Log.e('Failed to fetch environment URLs: $e');
    }
  }
}
