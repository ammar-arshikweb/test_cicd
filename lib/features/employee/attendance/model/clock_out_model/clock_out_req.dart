import 'package:panamera_app/utils/constant.dart';

class ClockOutReq {
  String dateTime;
  String checkOutDeviceId;
  double latitude;
  double longitude;

  ClockOutReq({required this.dateTime, required this.checkOutDeviceId, required this.latitude, required this.longitude});

  factory ClockOutReq.fromMap(Map<String, dynamic> map) {
    return ClockOutReq(
      dateTime: map[Constant.dateTime] as String,
      checkOutDeviceId: map[Constant.checkOutDeviceId] as String,
      latitude: map[Constant.latitude] as double,
      longitude: map[Constant.longitude] as double,
    );
  }

  Map<String, dynamic> toMap({bool isOfflineData = false}) {
    return {
      Constant.dateTime: dateTime,
      Constant.checkOutDeviceId: checkOutDeviceId,
      Constant.latitude: latitude,
      Constant.longitude: longitude,
      if (isOfflineData) Constant.isOfflineData: true,
    };
  }
}
