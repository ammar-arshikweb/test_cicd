import 'package:panamera_app/utils/constant.dart';

class EarlyLeaveRes {
  int attendanceRecordId;
  String earlyReason;

  EarlyLeaveRes({required this.attendanceRecordId, required this.earlyReason});

  factory EarlyLeaveRes.fromMap(Map<String, dynamic> map) {
    return EarlyLeaveRes(attendanceRecordId: map[Constant.attendanceRecordId] as int, earlyReason: map[Constant.earlyReason] as String);
  }

  Map<String, dynamic> toMap() {
    return {Constant.attendanceRecordId: attendanceRecordId, Constant.earlyReason: earlyReason};
  }
}
