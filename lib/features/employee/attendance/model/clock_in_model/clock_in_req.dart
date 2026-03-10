import 'package:panamera_app/utils/constant.dart';

class ClockInReq {
  String dateTime;
  String checkInDeviceId;
  double latitude;
  double longitude;

  ClockInReq({required this.dateTime, required this.checkInDeviceId, required this.latitude, required this.longitude});

  factory ClockInReq.fromMap(Map<String, dynamic> map) {
    return ClockInReq(
      dateTime: map[Constant.dateTime] as String,
      checkInDeviceId: map[Constant.checkInDeviceId] as String,
      latitude: map[Constant.latitude] as double,
      longitude: map[Constant.longitude] as double,
    );
  }

  Map<String, dynamic> toMap({bool isOfflineData = false}) {
    return {
      Constant.dateTime: dateTime,
      Constant.checkInDeviceId: checkInDeviceId,
      Constant.latitude: latitude,
      Constant.longitude: longitude,
      if (isOfflineData) Constant.isOfflineData: true,
    };
  }
}
