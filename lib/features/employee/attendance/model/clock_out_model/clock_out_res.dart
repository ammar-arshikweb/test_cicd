import 'package:panamera_app/utils/constant.dart';

class ClockOutRes {
  int attendanceId;
  String clockInTime;
  String clockOutTime;
  double workingHours;
  String attendanceStatus;
  dynamic overtimeHours;
  dynamic overtimeRequestId;
  String status;

  ClockOutRes({
    required this.attendanceId,
    required this.clockInTime,
    required this.clockOutTime,
    required this.workingHours,
    required this.attendanceStatus,
    required this.overtimeHours,
    this.overtimeRequestId,
    required this.status,
  });

  factory ClockOutRes.fromMap(Map<String, dynamic> map) {
    return ClockOutRes(
      attendanceId: map[Constant.attendanceId] as int,
      clockInTime: map[Constant.clockInTime] as String,
      clockOutTime: map[Constant.clockOutTime] as String,
      workingHours: map[Constant.workingHours] as double,
      attendanceStatus: map[Constant.attendanceStatus] as String,
      overtimeHours: map[Constant.overtimeHours],
      overtimeRequestId: map[Constant.overtimeRequestId],
      status: map[Constant.status] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
      Constant.clockInTime: clockInTime,
      Constant.clockOutTime: clockOutTime,
      Constant.workingHours: workingHours,
      Constant.attendanceStatus: attendanceStatus,
      Constant.overtimeHours: overtimeHours,
      Constant.overtimeRequestId: overtimeRequestId,
      Constant.status: status,
    };
  }
}
