import 'package:panamera_app/utils/constant.dart';

class ClockInOutStatusReq {
  String userId;

  ClockInOutStatusReq({required this.userId});

  factory ClockInOutStatusReq.fromMap(Map<String, dynamic> map) {
    return ClockInOutStatusReq(userId: map[Constant.userId] as String);
  }

  Map<String, dynamic> toMap() {
    return {Constant.userId: userId};
  }
}
