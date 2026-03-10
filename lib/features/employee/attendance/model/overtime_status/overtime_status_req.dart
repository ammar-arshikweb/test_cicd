import 'package:panamera_app/utils/constant.dart';

class OvertimeStatusReq {
  int attendanceId;
  int overtimeHours;
  int status;

  OvertimeStatusReq({required this.attendanceId, required this.overtimeHours, required this.status});

  factory OvertimeStatusReq.fromMap(Map<String, dynamic> map) {
    return OvertimeStatusReq(
      attendanceId: map[Constant.attendanceId] as int,
      overtimeHours: map[Constant.overtimeHours] as int,
      status: map[Constant.attendanceId] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {Constant.attendanceId: attendanceId, Constant.overtimeHours: overtimeHours, Constant.status: status};
  }
}
