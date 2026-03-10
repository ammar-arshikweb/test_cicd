import 'package:panamera_app/utils/constant.dart';

class BreakInRes {
  int attendanceId;
  String breakInTime;

  BreakInRes({required this.attendanceId, required this.breakInTime});

  factory BreakInRes.fromMap(Map<String, dynamic> map) {
    return BreakInRes(
      attendanceId: map[Constant.attendanceId] as int,
      breakInTime: map[Constant.breakInTime] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
      Constant.breakInTime: breakInTime,
    };
  }
}
