import 'package:panamera_app/utils/constant.dart';

class AppUpdateModel {
  final String latestVersion;
  final String minSupportedVersion;
  final String latestIosVersion;
  final String minIosVersion;
  final String androidUrl;
  final String iosUrl;

  AppUpdateModel({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.androidUrl,
    required this.iosUrl,
    required this.latestIosVersion,
    required this.minIosVersion,
  });

  factory AppUpdateModel.fromMap(Map<String, dynamic> json) {
    return AppUpdateModel(
      latestVersion: json[Constant.latestVersion] ?? '',
      minSupportedVersion: json[Constant.minSupportedVersion] ?? '',
      latestIosVersion: json[Constant.latestIosVersion] ?? '',
      minIosVersion: json[Constant.minIosVersion] ?? '',
      androidUrl: json[Constant.androidUrl] ?? '',
      iosUrl: json[Constant.iosUrl] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constant.latestVersion: latestVersion,
      Constant.minSupportedVersion: minSupportedVersion,
      Constant.latestIosVersion: latestIosVersion,
      Constant.minIosVersion: minIosVersion,
      Constant.androidUrl: androidUrl,
      Constant.iosUrl: iosUrl,
    };
  }
}
