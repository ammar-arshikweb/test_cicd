import 'package:panamera_app/utils/constant.dart';

class LogoutReq {
  String refreshToken;

  LogoutReq({required this.refreshToken});

  factory LogoutReq.fromJson(Map<String, dynamic> json) {
    return LogoutReq(
      refreshToken: json[Constant.refreshToken] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.refreshToken: refreshToken,
    };
  }
}