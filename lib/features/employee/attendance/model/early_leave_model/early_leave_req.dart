import 'package:panamera_app/utils/constant.dart';

class EarlyLeaveReq {
  int attendanceRecordId;
  String earlyReason;

  EarlyLeaveReq({required this.attendanceRecordId, required this.earlyReason});

  factory EarlyLeaveReq.fromMap(Map<String, dynamic> map) {
    return EarlyLeaveReq(attendanceRecordId: map[Constant.attendanceRecordId] as int, earlyReason: map[Constant.earlyReason] as String);
  }

  Map<String, dynamic> toMap({bool isOfflineData = false}) {
    return {Constant.attendanceRecordId: attendanceRecordId, Constant.earlyReason: earlyReason};
  }
}
