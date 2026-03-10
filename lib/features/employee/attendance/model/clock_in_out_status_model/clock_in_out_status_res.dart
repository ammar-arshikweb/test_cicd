import 'package:panamera_app/utils/constant.dart';

class ClockInOutStatusRes {
  String date;
  bool clockInStatus;
  String? clockInTime;
  bool clockOutStatus;
  String? clockOutTime;
  String? breakInTime;
  String? breakOutTime;
  String? shiftUpdateTime;
  int workingDaysInMonth;
  int absentDaysInMonth;
  int holidaysInMonth;
  double totalOvertimeInMonth;

  ClockInOutStatusRes({
    required this.date,
    required this.clockInStatus,
    this.clockInTime,
    required this.clockOutStatus,
    this.clockOutTime,
    this.breakInTime,
    this.breakOutTime,
    this.shiftUpdateTime,
    this.workingDaysInMonth = 0,
    this.absentDaysInMonth = 0,
    this.holidaysInMonth = 0,
    this.totalOvertimeInMonth = 0.0,
  });

  factory ClockInOutStatusRes.fromMap(Map<String, dynamic> map) {
    return ClockInOutStatusRes(
      date: map[Constant.date] as String,
      clockInStatus: map[Constant.clockInStatus] as bool,
      clockInTime: map[Constant.clockInTime] as String?,
      clockOutStatus: map[Constant.clockOutStatus] as bool,
      clockOutTime: map[Constant.clockOutTime] as String?,
      breakInTime: map[Constant.breakInTime] as String?,
      breakOutTime: map[Constant.breakOutTime] as String?,
      shiftUpdateTime: map[Constant.shiftUpdateTime] ?? '',
      workingDaysInMonth: map[Constant.workingDaysInMonth] as int? ?? 0,
      absentDaysInMonth: map[Constant.absentDaysInMonth] as int? ?? 0,
      holidaysInMonth: map[Constant.holidaysInMonth] as int? ?? 0,
      totalOvertimeInMonth: (map[Constant.totalOvertimeInMonth])?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.date: date,
      Constant.clockInStatus: clockInStatus,
      Constant.clockInTime: clockInTime,
      Constant.clockOutStatus: clockOutStatus,
      Constant.clockOutTime: clockOutTime,
      Constant.breakInTime: breakInTime,
      Constant.breakOutTime: breakOutTime,
      Constant.shiftUpdateTime: shiftUpdateTime,
      Constant.workingDaysInMonth: workingDaysInMonth,
      Constant.absentDaysInMonth: absentDaysInMonth,
      Constant.holidaysInMonth: holidaysInMonth,
      Constant.totalOvertimeInMonth: totalOvertimeInMonth,
    };
  }
}
