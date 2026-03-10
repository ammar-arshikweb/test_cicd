import 'package:panamera_app/utils/constant.dart';

class BreakOutRes {
  int attendanceId;
  String breakOutTime;

  BreakOutRes({
    required this.attendanceId,
    required this.breakOutTime,
  });

  factory BreakOutRes.fromMap(Map<String, dynamic> map) {
    return BreakOutRes(
      attendanceId: map[Constant.attendanceId] as int,
      breakOutTime: map[Constant.breakOutTime] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
      Constant.breakOutTime: breakOutTime,
    };
  }
}
