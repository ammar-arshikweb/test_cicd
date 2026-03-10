import 'package:panamera_app/utils/constant.dart';

class BreakInReq {
  String dateTime;

  BreakInReq({required this.dateTime});

  factory BreakInReq.fromMap(Map<String, dynamic> map) {
    return BreakInReq(
      dateTime: map[Constant.dateTime] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.dateTime: dateTime,
    };
  }
}
