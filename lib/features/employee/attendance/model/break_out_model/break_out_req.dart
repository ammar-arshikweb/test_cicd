import 'package:panamera_app/utils/constant.dart';

class BreakOutReq {
  String dateTime;

  BreakOutReq({required this.dateTime});

  factory BreakOutReq.fromMap(Map<String, dynamic> map) {
    return BreakOutReq(
      dateTime: map[Constant.dateTime] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.dateTime: dateTime,
    };
  }
}
