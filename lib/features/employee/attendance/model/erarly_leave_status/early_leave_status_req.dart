import 'package:panamera_app/utils/constant.dart';

class EarlyLeaveStatusReq {
  int attendanceId;
  int status;

  EarlyLeaveStatusReq({required this.attendanceId, required this.status});

  factory EarlyLeaveStatusReq.fromMap(Map<String, dynamic> map) {
    return EarlyLeaveStatusReq(attendanceId: map[Constant.attendanceId] as int, status: map[Constant.attendanceId] as int);
  }

  Map<String, dynamic> toMap() {
    return {Constant.attendanceId: attendanceId, Constant.status: status};
  }
}