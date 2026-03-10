import 'package:panamera_app/utils/constant.dart';

class ClockInRes {
  int attendanceId;
  String clockInTime;
  int? shiftId;

  ClockInRes({required this.attendanceId, required this.clockInTime, this.shiftId});

  factory ClockInRes.fromMap(Map<String, dynamic> map) {
    return ClockInRes(
      attendanceId: map[Constant.attendanceId] as int,
      clockInTime: map[Constant.clockInTime] as String,
      shiftId: map[Constant.shiftId],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
      Constant.clockInTime: clockInTime,
      Constant.shiftId: shiftId,
    };
  }
}
